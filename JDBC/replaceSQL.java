import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ReplaceSYSDATEWithShiteiDate {

    public static void main(String[] args) {
        String shiteiDate = getShiteiDate();

        String sql104 = "SELECT" +
            " TO_CHAR(RETTREMENT_DATE, 'YYYY/MM/DD') AS RETTREMENT_DATE" +
            " FROM SSO_RETTREMENT_AD" +
            " WHERE " +
            " TO_CHAR(AD_COOPERATION_DATE, 'YYYY/MM/DD') - TO_CHAR(SYSDATE, 'YYYY/MM/DD')" +
            " ORDER BY RETTREMENT_DATE";

        String sql101 = "SELECT" +
            " EMPLOYEE_NUMBER6," +
            " FIRST_NAME," +
            " LAST_NAME," +
            " TO_CHAR(RETTREMENT_DATE, 'YYYY/MM/DD') AS RETTREMENT_DATE" +
            " FROM SSO_ID_UNION_NEW" +
            " WHERE" +
            " TRIM(RETTREMENT_DATE) IS NOT NULL" +
            " AND RETTREMENT_DATE < TRUNC(SYSDATE, 'DD')" +
            " ORDER BY EMPLOYEE_NUMBER6";

        sql104 = sql104.replace("SYSDATE", "TO_DATE('" + shiteiDate + "', 'YYYY/MM/DD')");
        sql101 = sql101.replace("SYSDATE", "TO_DATE('" + shiteiDate + "', 'YYYY/MM/DD')");

        System.out.println("Updated SQL 104: " + sql104);
        System.out.println("Updated SQL 101: " + sql101);
    }

    public static String getShiteiDate() {
        String shiteiDate = "";
        try {
            Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "username", "password");
            PreparedStatement ps = conn.prepareStatement("SELECT PROPERTY_VAULE FROM T_ProPerties WHERE CATEGORY = 'DateShitei' AND PROPERTY_NAME = 'Shitei_Date'");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                shiteiDate = rs.getString("PROPERTY_VAULE");
            }
            rs.close(); 
            ps.close(); 
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return shiteiDate;
    }
}
