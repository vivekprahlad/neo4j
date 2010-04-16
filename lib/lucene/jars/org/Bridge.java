package org;

import org.apache.lucene.index.*;
import org.apache.lucene.store.*;
import org.apache.lucene.search.*;
import org.apache.lucene.document.*;

public class Bridge {

    public static String time_second(Long tt) {
        long t = tt.longValue();
        return org.apache.lucene.document.DateTools.timeToString(t, DateTools.Resolution.SECOND);
    }

    public static String time_day(Long tt) {
        long t = tt.longValue();
        return org.apache.lucene.document.DateTools.timeToString(t, DateTools.Resolution.DAY);
    }

    /*
static IndexReader	open(Directory directory, boolean readOnly) 
          Returns an IndexReader reading the index in the given Directory.
     */
    public static IndexReader open(Class reader, Directory directory, boolean readOnly) throws Exception {
        System.out.println("In Java");
        System.out.println("Dir: " + directory.getClass().toString());
        System.out.println("Dir, val " + directory.toString());
        try {
            IndexReader r = IndexReader.open(directory, readOnly);
            System.out.println("Opened reader " + reader.toString());
            return r;
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Error " + e.getMessage());
            throw new RuntimeException(e.getMessage());
        }
        //return reader.open(directory, readOnly);
    }

    public static IndexSearcher searcher(IndexReader reader) {
        System.out.println("Create IndexSearcher");
        System.out.println("Reader = " + reader.toString());
        return new IndexSearcher(reader);
    }
}
