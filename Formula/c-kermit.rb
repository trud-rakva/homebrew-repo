class CKermit < Formula
  desc "Scriptable network and serial communication for UNIX and VMS"
  homepage "https://www.kermitproject.org/"
  url "https://www.kermitproject.org/ftp/kermit/archives/cku302.tar.gz"
  version "9.0.302"
  sha256 "0d5f2cd12bdab9401b4c836854ebbf241675051875557783c332a6a40dac0711"

  # C-Kermit archive file names only contain the patch version and the full
  # version has to be obtained from text on the project page.
  livecheck do
    url "https://www.kermitproject.org/ckermit.html"
    regex(/The current C-Kermit release is v?(\d+(?:\.\d+)+) /i)
  end

  uses_from_macos "libxcrypt"
  uses_from_macos "ncurses"

  # Apply patch to fix build failure with glibc 2.28+
  # Will be fixed in next release: https://www.kermitproject.org/ckupdates.html
  patch :DATA

  def install
    system "make", "macosx"
    man1.mkpath

    # The makefile adds /man to the end of manroot when running install
    # hence we pass share here, not man.  If we don't pass anything it
    # uses {prefix}/man
    system "make", "prefix=#{prefix}", "manroot=#{share}", "install"
  end

  test do
    assert_match "C-Kermit #{version}",
                 shell_output("#{bin}/kermit -C VERSION,exit")
  end
end

__END__
--- z/ckucmd.c	2004-01-07 10:04:04.000000000 -0800
+++ k/ckucmd.c	2019-01-01 15:52:44.798864262 -0800
@@ -7103,7 +7103,7 @@
 
 /* Here we must look inside the stdin buffer - highly platform dependent */
 
-#ifdef _IO_file_flags			/* Linux */
+#ifdef _IO_EOF_SEEN			/* Linux */
     x = (int) ((stdin->_IO_read_end) - (stdin->_IO_read_ptr));
     debug(F101,"cmdconchk _IO_file_flags","",x);
 #else  /* _IO_file_flags */
--- ckcmai.c.orig	2011-08-20 23:20:42.000000000 +0200
+++ ckcmai.c	2020-11-07 06:54:10.000000000 +0100
@@ -1,7 +1,7 @@
 #define EDITDATE  "20 Aug 2011"		/* Last edit date dd mmm yyyy */
 #define EDITNDATE "20110820"		/* Keep them in sync */
 /* Sat Aug 20 17:20:17 2011 */
-
+#include <time.h>
 /* ckcmai.c - Main program for C-Kermit plus some miscellaneous functions */

 /*

--- ckuusx.c.orig	2011-06-17 16:11:34.000000000 +0200
+++ ckuusx.c	2020-12-02 09:30:29.000000000 +0100
@@ -28,6 +28,8 @@
 #include "ckcker.h"
 #include "ckuusr.h"
 #include "ckcxla.h"
+#include <curses.h>
+#include <term.h>

 #ifndef NOHTERMCAP
 #ifdef NOTERMCAP

--- ckupty.c.orig	2011-06-13 17:34:13.000000000 +0200
+++ ckupty.c	2020-12-02 09:17:03.000000000 +0100
@@ -56,6 +56,7 @@

 #include "ckcsym.h"
 #include "ckcdeb.h"			/* To pick up NETPTY definition */
+#include <util.h>

 #ifndef NETPTY				/* Selector for PTY support */

--- ckutio.c.orig	2011-08-20 23:22:35.000000000 +0200
+++ ckutio.c	2020-12-02 09:16:34.000000000 +0100
@@ -41,6 +41,7 @@

 #include "ckcsym.h"			/* This must go first   */
 #include "ckcdeb.h"			/* This must go second  */
+#include <util.h>

 #ifdef OSF13
 #ifdef CK_ANSIC
