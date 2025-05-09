<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Edit Health Checkup</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f5f5f5;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    form {
      background-color: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0,0,0,0.1);
      max-width: 500px;
      width: 100%;
    }

    h2 {
      text-align: center;
      color: #2C3E50;
      margin-bottom: 20px;
    }

    label {
      display: block;
      margin-top: 12px;
      font-weight: bold;
      color: #333;
    }

    input, select {
      width: 100%;
      padding: 8px;
      margin-top: 5px;
      border: 1px solid #ccc;
      border-radius: 5px;
    }

    button {
      margin-top: 20px;
      padding: 10px;
      width: 100%;
      background-color: #2C3E50;
      color: white;
      border: none;
      border-radius: 5px;
      cursor: pointer;
    }

    button:hover {
      background-color: #1A242F;
    }

    a {
      display: block;
      text-align: center;
      margin-top: 15px;
      color: #2C3E50;
      text-decoration: none;
    }
  </style>
</head>
<body>

<%
  String checkup_id = request.getParameter("checkup_id");
  String patient_id = "";
  String types_of_checkup = "";
  String results = "";

  // Fetch existing data for the selected checkup ID
  try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

    if (checkup_id != null) {
      String query = "SELECT * FROM health_checkup WHERE checkup_id = ?";
      PreparedStatement ps = con.prepareStatement(query);
      ps.setInt(1, Integer.parseInt(checkup_id));
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        patient_id = String.valueOf(rs.getInt("patient_id"));
        types_of_checkup = rs.getString("types_of_checkup");
        results = rs.getString("results");
      }
      rs.close();
      ps.close();
    }
  } catch (Exception e) {
%>
    <div style="color: red; text-align:center;">Error: <%= e.getMessage() %></div>
<%
  }

  String action = request.getParameter("action");
  if ("update".equals(action)) {
    try {
      String newPatientId = request.getParameter("patient_id");
      String newTypesOfCheckup = request.getParameter("types_of_checkup");
      String newResults = request.getParameter("results");

      Class.forName("oracle.jdbc.driver.OracleDriver");
      Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");
      String updateQuery = "UPDATE health_checkup SET patient_id=?, types_of_checkup=?, results=? WHERE checkup_id=?";
      PreparedStatement ps = con.prepareStatement(updateQuery);
      ps.setInt(1, Integer.parseInt(newPatientId));
      ps.setString(2, newTypesOfCheckup);
      ps.setString(3, newResults);
      ps.setInt(4, Integer.parseInt(checkup_id));
      ps.executeUpdate();
      ps.close();
      con.close();
%>
      <script>
        alert("Health checkup record updated successfully!");
        window.location.href = "checkup.jsp";
      </script>
<%
    } catch (Exception e) {
%>
      <div style="color: red; text-align:center;">Error: <%= e.getMessage() %></div>
<%
    }
  }
%>

<form method="post" action="edit_checkup.jsp">
  <h2>Edit Health Checkup Record</h2>

  <label for="checkup_id">Checkup ID</label>
  <input type="number" name="checkup_id" value="<%= checkup_id %>" readonly>

  <label for="patient_id">Patient ID</label>
  <input type="number" name="patient_id" value="<%= patient_id %>" required>

  <label for="types_of_checkup">Type of Checkup</label>
  <input type="text" name="types_of_checkup" value="<%= types_of_checkup %>" required>

  <label for="results">Results</label>
  <input type="text" name="results" value="<%= results %>" required>

  <input type="hidden" name="action" value="update">
  <button type="submit">Update Health Checkup</button>

  <a href="checkup.jsp">← Back to Records</a>
</form>

</body>
</html>
