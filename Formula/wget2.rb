class Wget2 < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftp.gnu.org/gnu/wget/wget2-2.0.0.tar.gz"
  sha256 "4fe2fba0abb653ecc1cc180bea7f04212c17e8fe05c85aaac8baeac4cd241544"

  depends_on "pkg-config" => :build
  depends_on "libidn2"
  depends_on "trud-rakva/repo/libressl"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--with-ssl=openssl",
                          "--with-libssl-prefix=#{Formula["libressl"].opt_prefix}",
                          "--disable-pcre",
                          "--disable-pcre2",
                          "--without-libpsl",
                          "--without-included-regex"
    system "make", "install"
  end

  test do
    system bin/"wget2", "-O", "/dev/null", "https://google.com"
  end
end
