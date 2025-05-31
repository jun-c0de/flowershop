<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="header.jsp" %>
<%@ include file="menuMag.jsp" %>
<%@ include file="dbconn.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String productUuid = request.getParameter("productUuid");

    if (sShopUuid == null || sShopUuid.isEmpty()) {
        out.println("<h3 style='color:red; text-align:center;'>잘못된 접근입니다. shopUuid가 필요합니다.</h3>");
        return;
    }

    if (productUuid == null || productUuid.isEmpty()) {
        out.println("<h3 style='color:red; text-align:center;'>잘못된 접근입니다. productUuid가 필요합니다.</h3>");
        return;
    }

    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String categoryCd = "";
    String productName = "";
    String productPrice = "";
    String productQuantity = "";
    String productDesc = "";

    try {
        String sqlSelect = "SELECT * FROM product WHERE product_uuid = ?";

        pstmt = conn.prepareStatement(sqlSelect);
        pstmt.setString(1, productUuid);

        rs = pstmt.executeQuery();

        if (rs.next()) {
            categoryCd = rs.getString("category_cd");
            productName = rs.getString("product_name");
            productPrice = rs.getString("product_price");
            productQuantity = rs.getString("product_quantity");
            productDesc = rs.getString("product_desc");
        } else {
            out.println("<h3 style='color:red; text-align:center;'>해당 상품을 찾을 수 없습니다.</h3>");
            return;
        }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>상품 수정</title>
<link rel="stylesheet" href="./style.css">
</head>
<body>

<h2 style="text-align:center;">상품 수정</h2>

<form id="frmProductSave" name="frmProductSave" action="productSaveMag.jsp" method="post">
    <input type="hidden" name="actionMethod" value="U">
    <input type="hidden" name="productUuid" value="<%= productUuid %>">
    <input type="hidden" name="shopUuid" value="<%= sShopUuid %>">

    <table border="1" style="width:60%; margin: 0 auto; border-collapse: collapse;">
        <tr>
            <th style="width: 30%;">카테고리</th>
            <td>
                <select name="categoryCd">
                    <option value="">선택</option>
                    <option value="01" <%= "01".equals(categoryCd) ? "selected" : "" %>>장미</option>
                    <option value="02" <%= "02".equals(categoryCd) ? "selected" : "" %>>백합</option>
                    <option value="03" <%= "03".equals(categoryCd) ? "selected" : "" %>>튤립</option>
                    <option value="04" <%= "04".equals(categoryCd) ? "selected" : "" %>>해바라기</option>
                </select>
            </td>
        </tr>
        <tr>
            <th>상품명</th>
            <td><input type="text" name="productName" style="width: 100%;" value="<%= productName %>"></td>
        </tr>
        <tr>
            <th>가격</th>
            <td><input type="text" name="productPrice" style="width: 100%;" value="<%= productPrice %>"></td>
        </tr>
        <tr>
            <th>수량</th>
            <td><input type="text" name="productQuantity" style="width: 100%;" value="<%= productQuantity %>"></td>
        </tr>
        <tr>
            <th>설명</th>
            <td><textarea name="productDesc" rows="4" style="width: 100%;"><%= productDesc %></textarea></td>
        </tr>
        <tr>
            <td colspan="2" style="text-align:center; padding: 10px;">
                <input type="submit" value="저장" style="padding: 5px 20px;">
                <input type="reset" value="취소" style="padding: 5px 20px;">
            </td>
        </tr>
    </table>
</form>

</body>
</html>

<%
    } catch(Exception e) {
        out.println("<p style='color:red; text-align:center;'>데이터 처리 중 오류가 발생했습니다.</p>");
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        e.printStackTrace(pw);
        out.println("<pre>" + sw.toString() + "</pre>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
