#! /bin/sh

while [ $# -gt 0 ]; do
	case "$1" in
	-v)
		set -x
		;;
	*)
		break
		;;
	esac
	shift
done

env USETOOLS=no MAKEOBJDIRPREFIX=/usr/obj/i386 sh -c 'cd ../lib && \
	make cleandir ; \
	su root -c "make includes"; \
	make ; \
	su root -c "make install"'
env USETOOLS=no MAKEOBJDIRPREFIX=/usr/obj/i386 sh -c 'cd ../netpgp && \
	make cleandir ; \
	make ; \
	su root -c "make install"'
env USETOOLS=no MAKEOBJDIRPREFIX=/usr/obj/i386 sh -c 'cd ../netpgpkeys && \
	make cleandir ; \
	make ; \
	su root -c "make install"'
env USETOOLS=no MAKEOBJDIRPREFIX=/usr/obj/i386 sh -c 'cd ../netpgpverify && \
	make cleandir ; \
	make ; \
	su root -c "make install"'

passed=0
total=36
rm -f passed
date > passed
echo "======> sign/verify 180938 file"
cp configure a
/usr/bin/netpgp --sign a
/usr/bin/netpgp --verify a.gpg && passed=$(expr $passed + 1)
echo "1 " $passed >> passed
echo "======> attempt to verify an unsigned file"
/usr/bin/netpgp --verify a || passed=$(expr $passed + 1)
echo "2 " $passed >> passed
echo "======> encrypt/decrypt 10809 file"
cp src/netpgp/netpgp.1 b
/usr/bin/netpgp --encrypt b
/usr/bin/netpgp --decrypt b.gpg
diff src/netpgp/netpgp.1 b && passed=$(expr $passed + 1)
echo "3 " $passed >> passed
echo "======> encrypt/decrypt 180938 file"
cp configure c
/usr/bin/netpgp --encrypt c
/usr/bin/netpgp --decrypt c.gpg
diff configure c && passed=$(expr $passed + 1)
echo "4 " $passed >> passed
echo "======> encrypt/decrypt bigass file"
cat configure configure configure configure configure configure > d
ls -l d
cp d e
/usr/bin/netpgp --encrypt d
/usr/bin/netpgp --decrypt d.gpg
diff e d && passed=$(expr $passed + 1)
echo "5 " $passed >> passed
echo "======> sign/verify detached signature file"
cat configure configure configure configure configure configure > f
/usr/bin/netpgp --sign --detached f
ls -l f f.sig
/usr/bin/netpgp --verify f.sig && passed=$(expr $passed + 1)
echo "6 " $passed >> passed
echo "======> cat signature - verified cat command"
/usr/bin/netpgp --cat a.gpg > a2
diff a a2 && passed=$(expr $passed + 1)
echo "7 " $passed >> passed
echo "======> another cat signature - verified cat command"
/usr/bin/netpgp --cat --output=a3 a.gpg
diff a a3 && passed=$(expr $passed + 1)
echo "8 " $passed >> passed
echo "======> netpgp list-packets test"
/usr/bin/netpgp --list-packets || passed=$(expr $passed + 1)
echo "9 " $passed >> passed
echo "======> version information"
/usr/bin/netpgp --version && passed=$(expr $passed + 1)
echo "10 " $passed >> passed
echo "======> netpgpverify file"
/usr/bin/netpgpverify a.gpg && passed=$(expr $passed + 1)
echo "11 " $passed >> passed
echo "======> attempt to verify an unsigned file"
/usr/bin/netpgpverify a || passed=$(expr $passed + 1)
echo "12 " $passed >> passed
echo "======> sign/verify detached signature file"
ls -l f f.sig
/usr/bin/netpgpverify f.sig && passed=$(expr $passed + 1)
echo "13 " $passed >> passed
echo "======> another verify signature - verified cat command"
/usr/bin/netpgpverify --output=a3 a.gpg
diff a a3 && passed=$(expr $passed + 1)
echo "14 " $passed >> passed
echo "======> list keys"
/usr/bin/netpgpkeys --list-keys && passed=$(expr $passed + 1)
echo "15 " $passed >> passed
echo "======> version information"
/usr/bin/netpgpverify --version && passed=$(expr $passed + 1)
echo "16 " $passed >> passed
echo "======> find specific key information"
/usr/bin/netpgpkeys --get-key c0596823 agc@netbsd.org && passed=$(expr $passed + 1)
echo "17 " $passed >> passed
echo "======> ascii armoured signature"
cp Makefile.am g
/usr/bin/netpgp --sign --armor g && passed=$(expr $passed + 1)
echo "18 " $passed >> passed
echo "======> ascii armoured sig detection and verification"
/usr/bin/netpgp --verify g.asc && passed=$(expr $passed + 1)
echo "19 " $passed >> passed
echo "======> ascii armoured signature of large file"
cp Makefile.in g
/usr/bin/netpgp --sign --armor g && passed=$(expr $passed + 1)
echo "20 " $passed >> passed
echo "======> ascii armoured sig detection and verification of large file"
/usr/bin/netpgp --verify g.asc && passed=$(expr $passed + 1)
echo "21 " $passed >> passed
echo "======> verify memory by recognising ascii armour"
/usr/bin/netpgp --cat < g.asc > g2
diff g g2 && passed=$(expr $passed + 1)
echo "22 " $passed >> passed
echo "======> list ssh host RSA public key"
/usr/bin/netpgpkeys --ssh --sshkeyfile=/etc/ssh/ssh_host_rsa_key.pub --list-keys && passed=$(expr $passed + 1)
echo "23 " $passed >> passed
echo "======> sign/verify file with ssh host keys"
cp configure a
sudo /usr/bin/netpgp --ssh --sshkeyfile=/etc/ssh/ssh_host_rsa_key.pub --sign a
sudo chmod 644 a.gpg
/usr/bin/netpgp --verify --ssh --sshkeyfile=/etc/ssh/ssh_host_rsa_key.pub a.gpg && passed=$(expr $passed + 1)
echo "24 " $passed >> passed
echo "======> pipeline and memory encrypt/decrypt"
/usr/bin/netpgp --encrypt < a | /usr/bin/netpgp --decrypt > a4
diff a a4 && passed=$(expr $passed + 1)
echo "25 " $passed >> passed
echo "======> pipeline and memory sign/verify"
/usr/bin/netpgp --sign < a | /usr/bin/netpgp --cat > a5
diff a a5 && passed=$(expr $passed + 1)
echo "26 " $passed >> passed
echo "======> verify within a duration"
cp Makefile.am h
/usr/bin/netpgp --sign --duration 6m --detached h
/usr/bin/netpgp --verify h.sig && passed=$(expr $passed + 1)
echo "27 " $passed >> passed
echo "======> invalid signature - expired"
rm -f h.sig
/usr/bin/netpgp --sign --duration 2 --detached h
sleep 3
/usr/bin/netpgp --verify h.sig || passed=$(expr $passed + 1)
echo "28 " $passed >> passed
echo "======> list signatures and subkey signatures"
/usr/bin/netpgpkeys --list-sigs && passed=$(expr $passed + 1)
echo "29 " $passed >> passed
echo "======> generate a new RSA key"
/usr/bin/netpgpkeys --generate-key && passed=$(expr $passed + 1)
echo "30 " $passed >> passed
echo "======> ascii detached armoured signature"
cp Makefile.am i
/usr/bin/netpgp --sign --armor --detached i && passed=$(expr $passed + 1)
echo "31 " $passed >> passed
echo "======> ascii detached armoured sig detection and verification"
/usr/bin/netpgp --verify i.asc && passed=$(expr $passed + 1)
echo "32 " $passed >> passed
echo "======> host ssh fingerprint and netpgp fingerprint"
netpgpkey=$(/usr/bin/netpgpkeys --ssh --sshkeyfile=/etc/ssh/ssh_host_rsa_key.pub --list-keys --hash=md5 | awk 'NR == 3 { print $3 $4 $5 $6 $7 $8 $9 $10 }')
sshkey=$(/usr/bin/ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub | awk '{ gsub(":", "", $2); print $2 }')
echo "host sshkey \"$sshkey\" = netpgpkey \"$netpgpkey\""
[ $sshkey = $netpgpkey ] && passed=$(expr $passed + 1)
echo "33 " $passed >> passed
echo "======> user ssh fingerprint and netpgp fingerprint"
netpgpkey=$(/usr/bin/netpgpkeys --ssh --list-keys --hash=md5 | awk 'NR == 3 { print $3 $4 $5 $6 $7 $8 $9 $10 }')
sshkey=$(/usr/bin/ssh-keygen -l -f /home/agc/.ssh/id_rsa.pub | awk '{ gsub(":", "", $2); print $2 }')
echo "user sshkey \"$sshkey\" = netpgpkey \"$netpgpkey\""
[ $sshkey = $netpgpkey ] && passed=$(expr $passed + 1)
echo "34 " $passed >> passed
echo "======> single key listing"
/usr/bin/netpgpkeys -l agc && passed=$(expr $passed + 1)
echo "35 " $passed >> passed
echo "======> pipeline and memory encrypt/decrypt with specified cipher"
/usr/bin/netpgp -e --cipher camellia128 < a | /usr/bin/netpgp -d > a6
diff a a6 && passed=$(expr $passed + 1)
echo "36 " $passed >> passed
rm -f a a.gpg b b.gpg c c.gpg d d.gpg e f f.sig g g.asc g2 a2 a3 a4 a5 a6 h h.sig i i.asc
echo "Passed ${passed}/${total} tests"
