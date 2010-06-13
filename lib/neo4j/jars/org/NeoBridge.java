package org;

import org.neo4j.graphdb.Node;

public class NeoBridge {

    public static void setProperty(Node node, String prop, byte[] data) {
        node.setProperty(prop, data);
    }

    public static byte[] getProperty(Node node, String prop) {
        byte[] bytes = (byte[]) node.getProperty(prop);
        return bytes;
    }

}
