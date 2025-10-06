class Openssh < Formula
  desc "OpenBSD SSH connectivity tools compiled with LibreSSL"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.1p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.1p1.tar.gz"
  version "10.1p1"
  sha256 "b9fc7a2b82579467a6f2f43e4a81c8e1dfda614ddb4f9b255aafd7020bbf0758"
  
  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "trud-rakva/repo/ldns"
  depends_on "trud-rakva/repo/libfido2"
  depends_on "trud-rakva/repo/libressl"

  uses_from_macos "lsof" => :test
  uses_from_macos "krb5"
  uses_from_macos "libedit"
  uses_from_macos "libxcrypt"
  uses_from_macos "zlib"

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
      --with-libedit
      --with-kerberos5
      --with-pam
      --with-ssl-dir=#{Formula["libressl"].opt_prefix}
      --with-ldns=#{Formula["ldns"].opt_prefix}
      --with-security-key-builtin
    ]

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")

    port = free_port
    fork { exec sbin/"sshd", "-D", "-p", port.to_s }
    sleep 2
    assert_match "sshd", shell_output("lsof -i :#{port}")
  end
end
