#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import getpass
import askpass
import base64
import paramiko
import socket

def uploadFiles(sftp,files):
    for file in files:
        name = os.path.basename(file)        
        if not os.path.exists(file):
            exit("Error: file " + file + " doesn't exist")
        
        if os.path.isdir(file):
            print "mkdir " + name
            remoteFiles = map(unicode.upper,sftp.listdir())
            if not name.upper() in remoteFiles and name!="/":
                sftp.mkdir(name)

            sftp.chdir(name)
            
            children = os.listdir(file)
            subfiles = []
            for child in children:
                subfiles.append(os.path.join(file,child))    

            uploadFiles(sftp, subfiles)
            
            sftp.chdir("..")
        else:    
            print "upload " + file
            sftp.put(file, name)
            # ftp.storbinary(('STOR ' + name).encode('utf-8'), open(file, 'rb'))
    
def sftpSession(server, port, account, passw, path, files):

    # get host key, if we know one
    hostkeytype = None
    hostkey = None
    try:
        host_keys = paramiko.util.load_host_keys(os.path.expanduser('~/.ssh/known_hosts'))
    except IOError:
        try:
            # try ~/ssh/ too, because windows can't have a folder named ~/.ssh/
            host_keys = paramiko.util.load_host_keys(os.path.expanduser('~/ssh/known_hosts'))
        except IOError:
            print('*** Unable to open host keys file')
            host_keys = {}

    if server in host_keys:
        hostkeytype = host_keys[server].keys()[0]
        hostkey = host_keys[server][hostkeytype]
        print('Using host key of type %s' % hostkeytype)
    
    try:
        t = paramiko.Transport((server, int(port)))
        t.connect(hostkey, account, passw, gss_host=socket.getfqdn(server),
                  gss_auth=False, gss_kex=False)
        sftp = paramiko.SFTPClient.from_transport(t)
        
        try:
            sftp.chdir('/')
            
            if path.endswith("/"):
                path = path[:-1]

            folders = []
            while 1:
                path, folder = os.path.split(path)
                if folder != "":
                    folders.append(folder)
                else:
                    if path != "":
                        folders.append(path)
                    break
        
            folders.reverse()
            folders = filter(lambda x: x!="/",folders)

            for folder in folders:
                
                remoteFiles = map(unicode.upper,sftp.listdir())
                if not folder.upper() in remoteFiles:
                    print "mkdir " + folder
                    sftp.mkdir(folder)
        
                sftp.chdir(folder)
            
            uploadFiles(sftp, files)
            
        except IOError:
            print('Error creating path')
               
        
    except Exception as e:
        print('*** Caught exception: %s: %s' % (e.__class__, e))
        traceback.print_exc()
        try:
            t.close()
        except:
            pass
    
    t.close()
    
    
