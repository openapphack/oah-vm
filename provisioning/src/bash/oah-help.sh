#!/bin/bash



function __oah_help {
	echo ""
	echo "Usage: oah <command> <candidate> [version]"
	echo "       oah offline <enable|disable>"
	echo ""
	echo "   commands:"
	echo "       install   or i    <candidate> [version]"
	echo "       uninstall or rm   <candidate> <version>"
	echo "       list      or ls   <candidate>"
	echo "       use       or u    <candidate> [version]"
	echo "       default   or d    <candidate> [version]"
	echo "       current   or c    [candidate]"
	echo "       outdated  or o    [candidate]"
	echo "       reset     or re   [candidate]"
	echo "       remove    or rm   [candidate]"
	echo "       up        or up"
  echo "       halt      or k"
  echo "       provision or p"
  echo "       destroy   or x"
	echo "       version   or v"
	echo "       broadcast or b"
	echo "       help      or h"
	echo "       offline           <enable|disable>"
	echo "       selfupdate        [force]"
	echo "       flush             <candidates|broadcast|archives|temp>"
	echo ""
	echo -n "   candidate  :  "
	echo "$OAH_CANDIDATES_CSV" | sed 's/,/, /g'
	echo "   version    :  where optional, defaults to latest stable if not provided"
	echo ""
	echo "eg: oah install oah-vm"
}
