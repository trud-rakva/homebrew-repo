class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  url "https://curl.se/download/curl-7.80.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-7_80_0/curl-7.80.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-7.80.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/legacy/curl-7.80.0.tar.bz2"
  sha256 "dd0d150e49cd950aff35e16b628edf04927f0289df42883750cf952bb858189c"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  depends_on "brotli"
  depends_on "libidn2"
  depends_on "libnghttp2"
  depends_on "libssh2"
  depends_on "openldap"
  depends_on "rtmpdump"
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
      --with-librtmp
      --with-libssh2
      --without-libpsl
      --with-gssapi
    ]
    # mk: remove openssl pkg-config to force libressl
    system 'export PKG_CONFIG_PATH="$(echo $PKG_CONFIG_PATH | sed "s/:[^:]*openssl[^:]*//")"' && 'echo $PKG_CONFIG_PATH'
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
