class Lrzsz < Formula
  desc "Tools for zmodem/xmodem/ymodem file transfer"
  homepage "https://www.ohse.de/uwe/software/lrzsz.html"
  url "https://www.ohse.de/uwe/releases/lrzsz-0.12.20.tar.gz"
  sha256 "c28b36b14bddb014d9e9c97c52459852f97bd405f89113f30bee45ed92728ff1"

  livecheck do
    url :homepage
    regex(/href=.*?lrzsz[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/trud-rakva/homebrew-repo/master/Patch/lrzsz/patch-man-lsz.diff"
    sha256 "71783e1d004661c03a1cdf77d0d76a378332272ea47bf29b1eb4c58cbf050a8d"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/trud-rakva/homebrew-repo/master/Patch/lrzsz/patch-po-Makefile.in.in.diff"
    sha256 "132facaeb102588e16d4ceecca67bc86b5a98b3c0cb6ffec7e7c4549abec574d"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/trud-rakva/homebrew-repo/master/Patch/lrzsz/patch-src-Makefile.in.diff"
    sha256 "51e5b0b9f0575c1dad18774e4a2c3ddf086c8e81c8fb7407a44584cfc18f73f6"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/trud-rakva/homebrew-repo/master/Patch/lrzsz/patch-zglobal.h.diff"
    sha256 "16c2097ceb2c5c9a6c4872aa9f903b57b557b428765d0f981579206c68f927b9"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/trud-rakva/homebrew-repo/master/Patch/lrzsz/implicit.patch"
    sha256 "215bcf3d21f8cb310c1a3de9a35184effe7f10d2e6ab4d91a65cfb436ddc5c4e"
  end

  # Patch CVE-2018-10195.
  # https://bugzilla.novell.com/show_bug.cgi?id=1090051
  patch :p0 do
    url "https://raw.githubusercontent.com/trud-rakva/homebrew-repo/master/Patch/lrzsz/patch-CVE-2018-10195.diff"
    sha256 "97f8ac95ebe4068250e18836ab5ad44f067ead90f8389d593d2dd8659a630099"
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-nls"
    system "make"

    # there's a bug in lrzsz when using custom --prefix
    # must install the binaries manually first
    bin.install "src/lrz", "src/lsz"

    system "make", "install"
    bin.install_symlink "lrz" => "rz", "lsz" => "sz"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lrb --help 2>&1")
  end
end
