<%@page import="java.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ include file="menuMag.jsp"%>
<%@ include file="dbconn.jsp"%>

<%
    request.setCharacterEncoding("UTF-8");
    String sOrderDt = request.getParameter("sOrderDt") == null ? "" : request.getParameter("sOrderDt");
    String sOrderStatus = request.getParameter("sOrderStatus") == null ? "" : request.getParameter("sOrderStatus");

    int totalQty = 0;
    int totalPrice = 0;

    // 주문번호별 행 수를 구하기 위해 Map 사용
    Map<String, Integer> orderCountMap = new HashMap<>();

    // OrderItem 클래스는 try 밖에서 선언
    class OrderItem {
        String orderUuid;
        String orderStatus;
        String orderStatusNm;
        int quantity;
        int price;
        String regDt;
        String productName;
    }

    List<OrderItem> orderList = new ArrayList<>();

    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        StringBuffer sql = new StringBuffer();
        sql.append("SELECT A.ORDER_UUID, A.ORDER_STATUS, ");
        sql.append("DECODE(A.ORDER_STATUS, 'PC', '결제완료', 'DC', '지급완료', 'CC', '취소완료') AS ORDER_STATUS_NM, ");
        sql.append("A.TOT_PRICE, A.REG_DT, ");
        sql.append("B.PRODUCT_UUID, B.QUANTITY, B.PRICE, ");
        sql.append("C.PRODUCT_NAME ");
        sql.append("FROM ORDER_MASTER A ");
        sql.append("INNER JOIN ORDER_ITEM B ON A.ORDER_UUID = B.ORDER_UUID ");
        sql.append("INNER JOIN PRODUCT C ON B.PRODUCT_UUID = C.PRODUCT_UUID ");
        sql.append("WHERE 1=1 ");

        if (!sOrderStatus.equals("")) {
            sql.append("AND A.ORDER_STATUS = ? ");
        }
        if (!sOrderDt.equals("")) {
            sql.append("AND TO_CHAR(A.REG_DT, 'YYYY-MM-DD') = ? ");
        }
        sql.append("ORDER BY A.REG_DT DESC");

        pstmt = conn.prepareStatement(sql.toString());
        int idx = 1;
        if (!sOrderStatus.equals("")) pstmt.setString(idx++, sOrderStatus);
        if (!sOrderDt.equals("")) pstmt.setString(idx++, sOrderDt);

        rs = pstmt.executeQuery();

        while (rs.next()) {
            OrderItem item = new OrderItem();
            item.orderUuid = rs.getString("ORDER_UUID");
            item.orderStatus = rs.getString("ORDER_STATUS");
            item.orderStatusNm = rs.getString("ORDER_STATUS_NM");
            item.quantity = rs.getInt("QUANTITY");
            item.price = rs.getInt("PRICE");
            item.regDt = rs.getString("REG_DT");
            item.productName = rs.getString("PRODUCT_NAME");

            orderList.add(item);

            if ("DC".equals(item.orderStatus)) {
                totalQty += item.quantity;
                totalPrice += (item.quantity * item.price);
            }

            orderCountMap.put(item.orderUuid, orderCountMap.getOrDefault(item.orderUuid, 0) + 1);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="./style.css">
<meta charset="UTF-8">
<title>주문관리</title>
</head>
<body>
	<h2 style="text-align: center;">주문관리</h2>

	<form id="frmOrderSearch" name="frmOrderSearch" action="orderMag.jsp"
		method="post" onsubmit="return false;">
		<div style="width: 90%; margin: 0 auto;">
			<label>주문일자</label> <input type="date" id="sOrderDt" name="sOrderDt"
				value="<%=sOrderDt%>"> <label>주문상태</label> <select
				id="sOrderStatus" name="sOrderStatus">
				<option value="">전체</option>
				<option value="PC"
					<%= "PC".equals(sOrderStatus) ? "selected" : "" %>>결제완료</option>
				<option value="DC"
					<%= "DC".equals(sOrderStatus) ? "selected" : "" %>>지급완료</option>
				<option value="CC"
					<%= "CC".equals(sOrderStatus) ? "selected" : "" %>>취소완료</option>
			</select> <input type="submit" onclick="search();" value="검색">
		</div>
	</form>

	<table border="1"
		style="width: 90%; margin: 20px auto; text-align: center;">
		<tr>
			<th>주문번호</th>
			<th>상품명</th>
			<th>가격</th>
			<th>수량</th>
			<th>주문일시</th>
			<th>주문상태</th>
			<th>기타</th>
		</tr>

		<%
        String prevOrderUuid = "";
        boolean firstRow;

        for (OrderItem item : orderList) {
            firstRow = !item.orderUuid.equals(prevOrderUuid); // 주문번호 변경 시 true
            int rowspan = orderCountMap.get(item.orderUuid);
        %>
		<tr>
            <% if (firstRow) { %>
			    <td rowspan="<%=rowspan%>"><%= item.orderUuid %></td>
            <% } %>

			<td><%= item.productName %></td>
			<td><%= item.price %></td>
			<td><%= item.quantity %></td>

            <% if (firstRow) { %>
			    <td rowspan="<%=rowspan%>"><%= item.regDt %></td>
			    <td rowspan="<%=rowspan%>"><%= item.orderStatusNm %></td>
			    <td rowspan="<%=rowspan%>">
                    <% if ("PC".equals(item.orderStatus)) { %>
                        <button onclick="orderComp('<%=item.orderUuid%>')">지급처리</button>
                        <button onclick="orderCancel('<%=item.orderUuid%>')">취소처리</button>
                    <% } %>
                </td>
            <% } %>
		</tr>
		<%
            prevOrderUuid = item.orderUuid;
        }
        %>
		<tr>
			<td colspan="2">합계</td>
			<td><%= totalPrice %></td>
			<td><%= totalQty %></td>
			<td colspan="3"></td>
		</tr>
	</table>

	<form id="frmOrder" name="frmOrder" action="orderComp.jsp"
		method="post">
		<input type="hidden" id="orderUuid" name="orderUuid"> <input
			type="hidden" id="orderStatus" name="orderStatus">
	</form>

	<script>
    function search() {
        document.getElementById("frmOrderSearch").submit();
    }

    function orderComp(orderUuid) {
        var frm = document.getElementById("frmOrder");
        frm.orderUuid.value = orderUuid;
        frm.orderStatus.value = "DC";
        frm.submit();
    }

    function orderCancel(orderUuid) {
        var frm = document.getElementById("frmOrder");
        frm.orderUuid.value = orderUuid;
        frm.orderStatus.value = "CC";
        frm.submit();
    }
</script>

</body>
</html>
