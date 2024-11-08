class Openvpn < Formula
  desc "SSL/TLS VPN implementing OSI layer 2 or 3 secure network extension"
  homepage "https://openvpn.net/community/"
  url "https://swupdate.openvpn.org/community/releases/openvpn-2.6.12.tar.gz"
  mirror "https://build.openvpn.net/downloads/releases/openvpn-2.6.12.tar.gz"
  sha256 "1c610fddeb686e34f1367c347e027e418e07523a10f4d8ce4a2c2af2f61a1929"

  livecheck do
    url "https://openvpn.net/community-downloads/"
    regex(/href=.*?openvpn[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "lz4"
  depends_on "lzo"
  depends_on "trud-rakva/repo/libressl"

  def install
    args = %W[
      OPENSSL_LIBS=-L#{Formula["libressl"].opt_prefix}/lib -lssl -lcrypto
      OPENSSL_CFLAGS=-I#{Formula["libressl"].opt_prefix}/include
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --with-crypto-library=openssl
      --prefix=#{prefix}
    ]
    system "./configure", *args 
    inreplace "sample/sample-plugins/Makefile" do |s|
      s.gsub! Superenv.shims_path/"pkg-config", Formula["pkg-config"].opt_bin/"pkg-config"
    end
    system "make", "install"

    inreplace "sample/sample-config-files/openvpn-startup.sh",
              "/etc/openvpn", etc/"openvpn"

    (doc/"samples").install Dir["sample/sample-*"]
    (etc/"openvpn").install doc/"samples/sample-config-files/client.conf"
    (etc/"openvpn").install doc/"samples/sample-config-files/server.conf"

    # We don't use mbedtls, so this file is unnecessary & somewhat confusing.
    rm doc/"README.mbedtls"
  end

  def post_install
    (var/"run/openvpn").mkpath
  end

  test do
    system sbin/"openvpn", "--show-ciphers"
  end
end
