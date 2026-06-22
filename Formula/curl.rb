class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  url "https://curl.se/download/curl-8.20.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_20_0/curl-8.20.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-8.20.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/legacy/curl-8.20.0.tar.bz2"
  sha256 "4be48e69cf467246cb97d369b85d78a08528f2b37cffef2418ee16e6a4eb596e"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => [:build, :test]

  depends_on "brotli"
  depends_on "libnghttp2"
  depends_on "libssh2"
  depends_on "zstd"
  depends_on "trud-rakva/repo/libressl"
  
  uses_from_macos "krb5"
  uses_from_macos "openldap"

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
      --with-libssh2
      --with-nghttp2
      --without-libpsl
      --with-apple-sectrust
      --with-gssapi
      --with-apple-idn
      --without-libidn2
    ]
    # mk: remove openssl pkgconfig to force use libressl
    system 'echo $PKG_CONFIG_PATH'
    ENV['PKG_CONFIG_PATH'] = `echo $PKG_CONFIG_PATH | sed 's/:[^:]*openssl[^:]*//'`
    system 'echo $PKG_CONFIG_PATH'
    
    system "./configure", *args, *std_configure_args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = testpath/"test.tar.gz"
    system bin/"curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    # Verify QUIC and HTTP3 support
    system bin/"curl", "--verbose", "--http3-only", "--head", "https://cloudflare-quic.com"

    # Check dependencies linked correctly
    curl_features = shell_output("#{bin}/curl-config --features").split("\n")
    %w[brotli GSS-API HTTP2 HTTP3 IDN libz SSL zstd].each do |feature|
      assert_includes curl_features, feature
    end
    curl_protocols = shell_output("#{bin}/curl-config --protocols").split("\n")
    %w[LDAPS SCP SFTP].each do |protocol|
      assert_includes curl_protocols, protocol
    end

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_path_exists testpath/"test.pem"
    assert_path_exists testpath/"certdata.txt"

    ENV["PKG_CONFIG_PATH"] = lib/"pkgconfig"
    ENV.append_path "PKG_CONFIG_PATH", Formula["zlib-ng-compat"].lib/"pkgconfig" unless OS.mac?
    system "pkgconf", "--cflags", "libcurl"
  end
end
