
public class AwardType {

    private long id;
    private String code;
    private String name;
    private long noteId;
    private String awardedBy;
    private String awardedFor;
    private String shortName;
    private boolean isPoll;
    private boolean nonGenre;

    public AwardType(long id, String code, String name, long noteId, String awardedBy, String awardedFor, String shortName, boolean isPoll, boolean nonGenre) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.noteId = noteId;
        this.awardedBy = awardedBy;
        this.awardedFor = awardedFor;
        this.shortName = shortName;
        this.isPoll = isPoll;
        this.nonGenre = nonGenre;
    }

    public void setIsPoll(boolean isPoll) {
        this.isPoll = isPoll;
    }

    public void setNonGenre(boolean nonGenre) {
        this.nonGenre = nonGenre;
    }

    public boolean isPoll() {

        return isPoll;
    }

    public boolean isNonGenre() {
        return nonGenre;
    }

    public long getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public long getNoteId() {
        return noteId;
    }

    public String getAwardedBy() {
        return awardedBy;
    }

    public String getAwardedFor() {
        return awardedFor;
    }

    public String getShortName() {
        return shortName;
    }

    public void setId(long id) {
        this.id = id;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setNoteId(long noteId) {
        this.noteId = noteId;
    }

    public void setAwardedBy(String awardedBy) {
        this.awardedBy = awardedBy;
    }

    public void setAwardedFor(String awardedFor) {
        this.awardedFor = awardedFor;
    }

    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    @Override
    public String toString() {
        return "AwardType { \n" +
                "   id=" + id + "\n" +
                "   code='" + code + "'\n" +
                "   name='" + name + "'\n" +
                "   noteId=" + noteId + "\n" +
                "   awardedBy='" + awardedBy + "'\n" +
                "   awardedFor='" + awardedFor + "'\n" +
                "   shortName='" + shortName + "'\n" +
                "   isPoll=" + isPoll + "\n" +
                "   nonGenre=" + nonGenre + "\n" +
                '}';
    }
}
