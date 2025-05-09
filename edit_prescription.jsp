<%@ page import="java.sql.*" %>
<%
  String prescription_id = request.getParameter("prescription_id");
  String appointment_id = request.getParameter("appointment_id");
  String patient_id = request.getParameter("patient_id");
  String doctor_id = request.getParameter("doctor_id");
  String prescription_date = request.getParameter("prescription_date");
  String medicine_id = request.getParameter("medicine_id");
  String notes = request.getParameter("notes");
  String action = request.getParameter("action");
  String updated = request.getParameter("updated");

  
  if (prescription_id == null) {
    prescription_id = "0";
  }
  if ("update".equals(action)) {
    try {
      // Database update logic
      Class.forName("oracle.jdbc.driver.OracleDriver");
      Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

      String query = "UPDATE prescription SET appointment_id=?, patient_id=?, doctor_id=?, prescription_date=TO_DATE(?, 'YYYY-MM-DD'), medicine_id=?, notes=? WHERE prescription_id=?";
      PreparedStatement ps = conn.prepareStatement(query);

      ps.setInt(1, Integer.parseInt(appointment_id));
      ps.setInt(2, Integer.parseInt(patient_id));
      ps.setInt(3, Integer.parseInt(doctor_id));
      ps.setString(4, prescription_date);
      ps.setInt(5, Integer.parseInt(medicine_id));
      ps.setString(6, notes);
      ps.setInt(7, Integer.parseInt(prescription_id));

      ps.executeUpdate();

      ps.close();
      conn.close();
%>
  <script>
    alert("Prescription updated successfully!");
    window.location.href = "edit_prescription.jsp?prescription_id=<%= prescription_id %>&updated=true";
  </script>
<%
    } catch (Exception e) {
%>
  <div style="color: red; text-align:center;">Error: <%= e.getMessage() %></div>
<%
    }
  }

  if ("true".equals(updated)) {
%>
  <div class="message success">✅ Prescription updated successfully!</div>
<%
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Edit Prescription</title>
  <style>
    * { box-sizing: border-box; }
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
    input, select, textarea {
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
  <form method="post" action="edit_prescription.jsp">
    <h2>Edit Prescription</h2>

    <label for="prescription_id">Prescription ID</label>
    <input type="number" name="prescription_id" value="<%= prescription_id %>" readonly>

    <label for="appointment_id">Appointment ID</label>
    <input type="number" name="appointment_id" value="<%= appointment_id %>" required>

    <label for="patient_id">Patient ID</label>
    <input type="number" name="patient_id" value="<%= patient_id %>" required>

    <label for="doctor_id">Doctor ID</label>
    <input type="number" name="doctor_id" value="<%= doctor_id %>" required>

    <label for="prescription_date">Prescription Date</label>
    <input type="date" name="prescription_date" value="<%= prescription_date != null ? prescription_date.substring(0, 10) : "" %>" required>

    <label for="medicine_id">Medicine ID</label>
    <input type="number" name="medicine_id" value="<%= medicine_id %>" required>

    <label for="notes">Notes</label>
    <textarea name="notes" required><%= notes != null ? notes : "" %></textarea>

    <input type="hidden" name="action" value="update">
    <button type="submit">Update Prescription</button>

    <a href="prescription.jsp">⬅ Back to Prescription List</a>
  </form>
</body>
</html>
