
import java.io.*;

public class Filtering {

    public static void main(String[] args) {

        String fileName = "Books/award_types.csv";
        parse(fileName);

    }

    public static void parse(String fileName) {

        File file = new File(fileName);

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {

            String line;
            while ((line = br.readLine()) != null) {

                // System.out.println(line);
                String[]arrayLine = line.split("\\t");

                long id;
                id = checkLong(arrayLine[0], "\\N");

                String code;
                code = checkString(arrayLine[1], "\\N");

                String name;
                name = checkString(arrayLine[2], "\\N");

                long noteId;
                noteId = checkLong(arrayLine[3], "\\N");

                String awardedBy;
                awardedBy = checkString(arrayLine[4], "\\N");

                String awardedFor;
                awardedFor = checkString(arrayLine[5], "\\N");

                String shortName;
                shortName = checkString(arrayLine[6], "\\N");

                boolean isPoll;
                isPoll = checkBoolean(arrayLine[7]);

                boolean nonGenre;
                nonGenre = checkBoolean(arrayLine[8]);


                AwardType at = new AwardType(id, code, name, noteId, awardedBy, awardedFor, shortName, isPoll, nonGenre);
                System.out.println(at);

                System.out.println();

            }

            br.close();

        } catch (IOException e) {
            e.printStackTrace();
        }

    }


    public static String checkString(String s, String pattern) {
        return s.equals(pattern) ? "NULL" : s;
    }

    public static long checkLong(String s, String pattern) {
        return s.equals(pattern) ? -666 : Long.parseLong(s);
    }

    public static boolean checkBoolean(String s) {
        switch (s) {
            case "Yes": return true;
            case "No": return false;
            default: return false;      // In reality, should return NULL
        }
    }

}
