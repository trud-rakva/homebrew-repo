class Wget2 < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftp.gnu.org/gnu/wget/wget2-2.0.0.tar.gz"
  sha256 "4fe2fba0abb653ecc1cc180bea7f04212c17e8fe05c85aaac8baeac4cd241544"

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gnutls"
  depends_on "gpgme"
  depends_on "libpsl"
  depends_on "nghttp2"
  
  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"
    
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    system bin/"wget2", "-O", "/dev/null", "https://google.com"
  end
end
