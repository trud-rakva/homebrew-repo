class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  url "https://curl.se/download/curl-8.4.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_4_0/curl-8.4.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-8.4.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/legacy/curl-8.4.0.tar.bz2"
  sha256 "e5250581a9c032b1b6ed3cf2f9c114c811fc41881069e9892d115cc73f9e88c6"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  depends_on "brotli"
  depends_on "libidn2"
  depends_on "libnghttp2"
  depends_on "libssh2"
  depends_on "zstd"
  depends_on "trud-rakva/repo/libressl"
  
  uses_from_macos "krb5"
  uses_from_macos "zlib"

  def install

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-ssl=#{Formula["libressl"].opt_prefix}
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-secure-transport
      --with-libidn2
      --with-libssh2
      --without-libpsl
      --with-gssapi
    ]
    # mk: remove openssl pkgconfig to force use libressl
    system 'echo $PKG_CONFIG_PATH'
    ENV['PKG_CONFIG_PATH'] = `echo $PKG_CONFIG_PATH | sed 's/:[^:]*openssl[^:]*//'`
    system 'echo $PKG_CONFIG_PATH'
    
    system "./configure", *args
    system "make", "install"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_predicate testpath/"test.pem", :exist?
    assert_predicate testpath/"certdata.txt", :exist?
  end
end
