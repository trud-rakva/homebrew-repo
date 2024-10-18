class Wget2 < Formula
  desc "Successor of GNU Wget, a file and recursive website downloader"
  homepage "https://gitlab.com/gnuwget/wget2"
  url "https://ftp.gnu.org/gnu/wget/wget2-2.1.0.tar.gz"
  sha256 "a05dc5191c6bad9313fd6db2777a78f5527ba4774f665d5d69f5a7461b49e2e7"

  depends_on "doxygen" => :build
  depends_on "gnu-sed" => :build
  depends_on "graphviz" => :build
  depends_on "lzlib" => :build # static lib
  depends_on "pandoc" => :build
  depends_on "pkg-config" => :build
  depends_on "texinfo" => :build # Build fails with macOS-provided `texinfo`

  depends_on "brotli"
  depends_on "gettext"
  depends_on "gnutls"
  depends_on "gpgme"
  depends_on "libidn2"
  depends_on "libnghttp2"
  depends_on "libpsl"
  depends_on "pcre2"
  depends_on "xz"
  depends_on "zstd"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  def install
    gnused = Formula["gnu-sed"]
    lzlib = Formula["lzlib"]
    gettext = Formula["gettext"]

    # The pattern used in 'docs/wget2_md2man.sh.in' doesn't work with system sed
    ENV.prepend_path "PATH", gnused.libexec/"gnubin"
    ENV.append "LZIP_CFLAGS", "-I#{lzlib.include}"
    ENV.append "LZIP_LIBS", "-L#{lzlib.lib} -llz"

    system "./configure", *std_configure_args,
           "--with-bzip2",
           "--with-lzma",
           "--with-libintl-prefix=#{gettext.prefix}"

    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wget2 --version")
  end
end
