require 'formula'

class JJDeploy < Formula
  homepage 'https://github.com/buscarini/jjdeploy'
  url 'https://github.com/buscarini/jjdeploy/archive/__VERSION__.tar.gz'
  sha1 '__SHA__'

  depends_on 'xcproj' => :recommended

  def install
    prefix.install 'jjdeploy_resources'

    bin.install 'jjdeploy'
  end

  test do
    system "#{bin}/jjdeploy", '--version'
  end
end