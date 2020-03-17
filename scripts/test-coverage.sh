echo removing _coverage dir
rm -rf _coverage
rm junit.xml

echo patching dune file
gsed -i '$i \(preprocess (pps bisect_ppx))\' lib/dune

echo running tests
BISECT_ENABLE=yes REPORT_PATH=./junit.xml esy test

cp $(esy echo "#{self.target_dir / 'default' / 'lib_test' / 'junit.xml'}") ./junit.xml

echo generating reports
esy bisect-ppx-report html
esy bisect-ppx-report summary

echo reseting files
git checkout lib/dune
