javac -cp lucene-core-2.9.1.jar org/Bridge.java
rm -rf pack
mkdir pack
cp -r org pack
cd pack
find -name *.java -exec rm {} \;
find -name *~ -exec rm {} \;
jar cf bridge.jar .
cd ..
mv pack/bridge.jar .
rm -rf pack

