<%@ page import="java.sql.*" %>
<html>
<head>
    <title>User Login</title>
</head>
<body>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if (username != null && password != null) {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection conn = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521:xe", "system", "a123"
            );

            String query = "SELECT * FROM login WHERE username = ? AND password = ?";
            PreparedStatement pstmt = conn.prepareStatement(query);
            pstmt.setString(1, username);
            pstmt.setString(2, password);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                // Login successful
                response.sendRedirect("index.html");
            } else {
%>
                <h3 style="color: red;">❌ Invalid username or password.</h3>
<%
            }

            rs.close();
            pstmt.close();
            conn.close();
        } catch (SQLException e) {
            out.print("<h3 style='color:red;'>SQL Error: " + e.getMessage() + "</h3>");
        } catch (Exception e) {
            out.print("<h3 style='color:red;'>Unexpected Error: " + e.getMessage() + "</h3>");
        }
    } else {
%>
    <h3>Please enter both username and password.</h3>
<%
    }
%>
</body>
</html>
