class Autoconf < Formula
  desc "Automatic configure script builder"
  homepage "https://www.gnu.org/software/autoconf"
  url "https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz"
  mirror "https://ftpmirror.gnu.org/autoconf/autoconf-2.71.tar.gz"
  sha256 "431075ad0bf529ef13cb41e9042c542381103e80015686222b8a9d4abef42a1c"
  license all_of: [
    "GPL-3.0-or-later",
    "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
  ]

  bottle do
    rebuild 4
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "e56508f2b40d96057225de13bc9ac27f1c64f4c120a5c73f34864a1669073fc9"
    sha256 cellar: :any_skip_relocation, big_sur:       "4a05c5734bd99dc0adca0160e1ca79a291f2bd7fb8d52dd4605df0da3063c891"
    sha256 cellar: :any_skip_relocation, catalina:      "ca510b350e941fb9395522a03f9d2fb5df276085d806ceead763acb95889a368"
    sha256 cellar: :any_skip_relocation, mojave:        "9724736d34773b6e41e2434ffa28fe79feccccf7b7786e54671441ca75115cdb"
    sha256 cellar: :any_skip_relocation, high_sierra:   "63957a3952b7af5496012b3819c9956822fd7d895d63339c23fdc65c502e1a40"
    sha256 cellar: :any_skip_relocation, sierra:        "a76fca79a00f733c1c9f75600b906de4755dd3fbb595b1b55ded1347ac141607"
    sha256 cellar: :any_skip_relocation, el_capitan:    "ded69c7dac4bc8747e52dca37d6d561e55e3162649d3805572db0dc2f940a4b8"
    sha256 cellar: :any_skip_relocation, yosemite:      "daf70656aa9ff8b2fb612324222aa6b5e900e2705c9f555198bcd8cd798d7dd0"
    sha256 cellar: :any_skip_relocation, mavericks:     "d153b3318754731ff5e91b45b2518c75880993fa9d1f312a03696e2c1de0c9d5"
  end

  depends_on "m4"
  uses_from_macos "perl"

  def install
    on_macos do
      ENV["PERL"] = "/usr/bin/perl"

      # force autoreconf to look for and use our glibtoolize
      inreplace "bin/autoreconf.in", "libtoolize", "glibtoolize"
      # also touch the man page so that it isn't rebuilt
      inreplace "man/autoreconf.1", "libtoolize", "glibtoolize"
    end

    system "./configure", "--prefix=#{prefix}", "--with-lispdir=#{elisp}"
    system "make", "install"

    rm_f info/"standards.info"
  end

  test do
    cp pkgshare/"autotest/autotest.m4", "autotest.m4"
    system bin/"autoconf", "autotest.m4"

    (testpath/"configure.ac").write <<~EOS
      AC_INIT([hello], [1.0])
      AC_CONFIG_SRCDIR([hello.c])
      AC_PROG_CC
      AC_OUTPUT
    EOS
    (testpath/"hello.c").write "int foo(void) { return 42; }"

    system bin/"autoconf"
    system "./configure"
    assert_predicate testpath/"config.status", :exist?
    assert_match(/\nCC=.*#{ENV.cc}/, (testpath/"config.log").read)
  end
end
