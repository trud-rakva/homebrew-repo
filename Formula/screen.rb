class Screen < Formula
  desc "Terminal multiplexer with VT100/ANSI terminal emulation"
  homepage "https://www.gnu.org/software/screen/"
  url "https://ftp.gnu.org/gnu/screen/screen-5.0.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/screen/screen-5.0.1.tar.gz"
  sha256 "2dae36f4db379ffcd14b691596ba6ec18ac3a9e22bc47ac239789ab58409869d"
  head "https://git.savannah.gnu.org/git/screen.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  uses_from_macos "libxcrypt"
  uses_from_macos "ncurses"

  def install
    args = %W[
      --mandir=#{man}
      --infodir=#{info}
      --enable-pam
    ]

    system "./autogen.sh"

    # Exclude unrecognized options
    std_args = std_configure_args.reject { |s| s["--disable-debug"] || s["--disable-dependency-tracking"] }
    system "./configure", *args, *std_args
    system "make", "install"
  end

  test do
    system bin/"screen", "-h"
  end
end
