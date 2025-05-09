<%@ page import="java.sql.*" %>
<%
  String appointment_id = request.getParameter("appointment_id");
  String doctor_id = request.getParameter("doctor_id");
  String patient_id = request.getParameter("patient_id");
  String appointment = request.getParameter("appointment");
  String purpose = request.getParameter("purpose");
  String status = request.getParameter("status");
  String action = request.getParameter("action");

  if ("update".equals(action)) {
    try {
      Class.forName("oracle.jdbc.driver.OracleDriver");
      Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

      String query = "UPDATE appointment SET doctor_id=?, patient_id=?, appointment=TO_DATE(?, 'YYYY-MM-DD\"T\"HH24:MI'), purpose=?, status=? WHERE appointment_id=?";
      PreparedStatement ps = con.prepareStatement(query);
      ps.setInt(1, Integer.parseInt(doctor_id));
      ps.setInt(2, Integer.parseInt(patient_id));
      ps.setString(3, appointment);
      ps.setString(4, purpose);
      ps.setString(5, status);
      ps.setInt(6, Integer.parseInt(appointment_id));
      ps.executeUpdate();

      ps.close();
      con.close();
%>
  <script>
    alert("Appointment updated successfully!");
    window.location.href = "appointment.jsp";
  </script>
<%
    } catch (Exception e) {
%>
  <div style="color: red; text-align:center;">Error: <%= e.getMessage() %></div>
<%
    }
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Update Appointment</title>
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
  <form method="post" action="edit_appointment.jsp">
    <h2>Update Appointment</h2>

    <label for="appointment_id">Appointment ID</label>
    <input type="number" name="appointment_id" value="<%= appointment_id %>" readonly>

    <label for="doctor_id">Doctor ID</label>
    <input type="number" name="doctor_id" value="<%= doctor_id %>" required>

    <label for="patient_id">Patient ID</label>
    <input type="number" name="patient_id" value="<%= patient_id %>" required>

    <label for="appointment">Appointment Date</label>
    <input type="datetime-local" name="appointment" value="<%= (appointment != null ? appointment.replace(" ", "T") : "") %>" required>

    <label for="purpose">Purpose</label>
    <input type="text" name="purpose" value="<%= purpose %>" required>

    <label for="status">Status</label>
    <select name="status" required>
      <option value="Confirmed" <%= "Confirmed".equals(status) ? "selected" : "" %>>Confirmed</option>
      <option value="Pending" <%= "Pending".equals(status) ? "selected" : "" %>>Pending</option>
    </select>

    <input type="hidden" name="action" value="update">
    <button type="submit">Update Appointment</button>

    <a href="appointment.jsp">← Back to Appointments</a>
  </form>
</body>
</html>
