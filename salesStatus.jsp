<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="header.jsp" %>
<%@ include file="menuMag.jsp" %>
<%@ include file="dbconn.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String sCategoryCd = request.getParameter("sCategoryCd");
    String sRegDt = request.getParameter("sRegDt");

    if (sCategoryCd == null) sCategoryCd = "";
    if (sRegDt == null) sRegDt = "";

    PreparedStatement pstmt = null;
    ResultSet rs = null;

    int iTotQuantity = 0;
    int iTotPrice = 0;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<span><a href="salesStatus.jsp">월별 일 판매량 및 판매금액</a> | <a href="salesStatus2.jsp">월별 일 판매량 및 판매금액</a></span>
<title>월별 일 판매량 및 판매금액</title>

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script>
var arrData = [];
arrData.push(["일자", "금액", "수량"]);
function search() {
    document.getElementById("frmSearch").submit();
}
</script>

<style>
  /* 화면 반반 레이아웃을 위한 flex container */
  .container {
    display: flex;
    width: 90%;
    margin: 20px auto;
    height: 450px; /* 차트와 테이블 높이 맞춤 */
    gap: 20px;
  }

  .left, .right {
    flex: 1;
    overflow-y: auto; /* 내용 넘치면 스크롤 */
    border: 1px solid #ddd;
    padding: 10px;
    box-sizing: border-box;
    background-color: #fafafa;
  }

  table {
    border-collapse: collapse;
    width: 100%;
  }
  table, th, td {
    border: 1px solid #bbb;
  }
  th, td {
    padding: 8px;
  }
  th {
    background-color: #eee;
  }
  th, td {
    text-align: right;
  }
  th:first-child, td:first-child {
    text-align: center;
  }
</style>
</head>
<body>

<h2 style="text-align:center;">월별 일 판매량 및 판매금액</h2>

<form id="frmSearch" name="frmSearch" action="salesStatus.jsp" method="post" onsubmit="return false;" style="width:90%; margin:auto 5%;">
  <label>카테고리</label>
  <select id="sCategoryCd" name="sCategoryCd">
    <option value="" <%= "".equals(sCategoryCd) ? "selected" : "" %>>전체</option>
    <option value="01" <%= "01".equals(sCategoryCd) ? "selected" : "" %>>Coffee</option>
    <option value="02" <%= "02".equals(sCategoryCd) ? "selected" : "" %>>NonCoffee</option>
    <option value="03" <%= "03".equals(sCategoryCd) ? "selected" : "" %>>Ade</option>
    <option value="04" <%= "04".equals(sCategoryCd) ? "selected" : "" %>>Smoothie</option>
  </select>
  <label>년월</label>
  <input type="month" id="sRegDt" name="sRegDt" style="width:120px;" value="<%= sRegDt %>">
  <input type="submit" onclick="search();" value="검색">
</form>

<div class="container">
  <div class="left">
    <table>
      <thead>
        <tr>
          <th>일자</th>
          <th>수량</th>
          <th>금액</th>
        </tr>
      </thead>
      <tbody>
<%
    if(conn != null && !conn.isClosed()) {
        StringBuffer sql = new StringBuffer();
        sql.append("/* salesStatus - 월별 일자별 LIST */\n");
        sql.append("SELECT TO_CHAR(B.REG_DT, 'MM-DD') REG_DAY\n");
        sql.append("     , SUM(B.QUANTITY) QUANTITY\n");
        sql.append("     , SUM(B.PRICE) PRICE\n");
        sql.append("  FROM ORDER_MASTER A\n");
        sql.append(" INNER JOIN ORDER_ITEM B ON A.ORDER_UUID = B.ORDER_UUID\n");
        sql.append(" INNER JOIN PRODUCT C ON B.PRODUCT_UUID = C.PRODUCT_UUID\n");
        sql.append(" WHERE 1=1\n");
        sql.append("   AND A.ORDER_STATUS = 'DC'\n");

        int iSetNum = 1;
        if(sCategoryCd != null && !"".equals(sCategoryCd)) {
            sql.append(" AND C.CATEGORY_CD = ?\n");
        }
        if(sRegDt != null && !"".equals(sRegDt)) {
            sql.append(" AND TO_CHAR(B.REG_DT, 'YYYY-MM') = ?\n");
        }
        sql.append(" GROUP BY TO_CHAR(B.REG_DT, 'MM-DD')\n");
        sql.append(" ORDER BY TO_CHAR(B.REG_DT, 'MM-DD') ASC\n");

        pstmt = conn.prepareStatement(sql.toString());

        if(sCategoryCd != null && !"".equals(sCategoryCd)) {
            pstmt.setString(iSetNum++, sCategoryCd);
        }
        if(sRegDt != null && !"".equals(sRegDt)) {
            pstmt.setString(iSetNum++, sRegDt);
        }

        rs = pstmt.executeQuery();

        int iResult = 0;
        while(rs.next()) {
            String regDay = rs.getString("REG_DAY");
            int iQuantity = rs.getInt("QUANTITY");
            int iPrice = rs.getInt("PRICE");

            iTotQuantity += iQuantity;
            iTotPrice += iPrice;

%>
<script>
arrData.push(["<%= regDay %>", <%= iPrice %>, <%= iQuantity %>]);
</script>

<tr>
  <td><%= regDay %></td>
  <td><%= iQuantity %></td>
  <td><%= iPrice %></td>
</tr>
<%
            iResult++;
        }
        if(iResult == 0) {
%>
<tr>
  <td colspan="3" style="text-align:center;">검색된 데이터가 없습니다.</td>
</tr>
<%
        }
    } else {
%>
<tr>
  <td colspan="3" style="text-align:center; color:red;">데이터베이스 연결이 없습니다.</td>
</tr>
<%
    }
%>
      </tbody>
      <tfoot>
        <tr>
          <th>합계</th>
          <th><%= iTotQuantity %></th>
          <th><%= iTotPrice %></th>
        </tr>
      </tfoot>
    </table>
  </div>

  <div class="right">
    <div id="columnchart_values" style="width: 100%; height: 100%;"></div>
  </div>
</div>

<script type="text/javascript">
  google.charts.load("current", {packages:['corechart']});
  google.charts.setOnLoadCallback(drawChart);

  function drawChart() {
    var data = google.visualization.arrayToDataTable(arrData);

    var options = {
      title: "월별 일 판매량 및 판매금액",
      height: 430,
      vAxes: {
        0: {title: '금액'},
        1: {title: '수량'}
      },
      series: {
        0: {targetAxisIndex: 0, type: 'bars'},
        1: {targetAxisIndex: 1, type: 'line'}
      },
      hAxis: {title: '일자'},
      legend: { position: 'bottom' }
    };

    var chart = new google.visualization.ComboChart(document.getElementById("columnchart_values"));
    chart.draw(data, options);
  }
</script>

</body>
</html>
