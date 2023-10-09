class Wget2 < Formula
  desc "Successor of GNU Wget, a file and recursive website downloader"
  homepage "https://gitlab.com/gnuwget/wget2"
  url "https://gitlab.com/gnuwget/wget2/uploads/83752270de83e103306576e67a1c7c80/wget2-2.0.1.tar.gz"
  sha256 "0bb7fa03697bb5b8d05e1b5e15b863440826eb845874c4ffb5e32330f9845db1"

  depends_on "doxygen" => :build
  # The pattern used in 'docs/wget2_md2man.sh.in' doesn't work with system sed
  depends_on "gnu-sed" => :build
  depends_on "graphviz" => :build
  depends_on "lzip" => :build
  depends_on "pandoc" => :build
  depends_on "pkg-config" => :build
  depends_on "texinfo" => :build # Build fails with macOS-provided `texinfo`

  depends_on "brotli"
  depends_on "gettext"
  depends_on "gnutls"
  depends_on "gpgme"
  depends_on "libassuan"
  depends_on "libgpg-error"
  depends_on "libidn2"
  depends_on "libmicrohttpd"
  depends_on "libnghttp2"
  depends_on "libpsl"
  depends_on "libtasn1"
  depends_on "lzlib"
  depends_on "nettle"
  depends_on "p11-kit"
  depends_on "pcre2"
  depends_on "xz"
  depends_on "zstd"

  uses_from_macos "bzip2"
  uses_from_macos "icu4c"
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
