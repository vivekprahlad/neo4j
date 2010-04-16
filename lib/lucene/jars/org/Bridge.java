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

    public static Sort create_sort(SortField[] fields) {
        return new Sort(fields);
    }
}
