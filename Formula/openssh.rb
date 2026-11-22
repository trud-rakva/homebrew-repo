class Openssh < Formula
  desc "OpenBSD SSH connectivity tools compiled with LibreSSL"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p2.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p2.tar.gz"
  version "10.6p2"
  sha256 "9ae44872090cf2f06b3cf9ff147e7f16f309671340763ed2f99248398ae29d5b"
  
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

  resource "com.openssh.sshd.sb" do
    url "https://raw.githubusercontent.com/apple-oss-distributions/OpenSSH/OpenSSH-268.100.4/com.openssh.sshd.sb"
    sha256 "a273f86360ea5da3910cfa4c118be931d10904267605cdd4b2055ced3a829774"
  end
  
  def install
    ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__"

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

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"

    buildpath.install resource("com.openssh.sshd.sb")
    (etc/"ssh").install "com.openssh.sshd.sb" => "org.openssh.sshd.sb"

    # Don't hardcode Cellar paths in configuration files
    inreplace etc/"ssh/sshd_config", prefix, opt_prefix
  end

  test do
    (etc/"ssh").find do |pn|
      next unless pn.file?

      refute_match HOMEBREW_CELLAR.to_s, pn.read
    end

    assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")

    port = free_port
    fork { exec sbin/"sshd", "-D", "-p", port.to_s }
    sleep 2
    assert_match "sshd", shell_output("lsof -i :#{port}")
  end
end
