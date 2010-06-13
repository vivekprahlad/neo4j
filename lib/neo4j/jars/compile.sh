javac -cp neo4j-kernel-1.0.jar org/NeoBridge.java
rm -rf pack
mkdir pack
cp -r org pack
cd pack
find -name *.java -exec rm {} \;
find -name *~ -exec rm {} \;
jar cf neobridge.jar .
cd ..
mv pack/neobridge.jar .
rm -rf pack

