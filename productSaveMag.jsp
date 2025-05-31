<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="dbconn.jsp" %>
<%@ include file="globalVar.jsp" %> <!-- sShopUuid 변수 포함 중인데, 이번엔 안 씀 -->

<%
    request.setCharacterEncoding("UTF-8");

    String sActionMethod = request.getParameter("actionMethod"); // "I" or "U"
    String sProductUuid = request.getParameter("productUuid"); // 수정 시 필요

    // shopUuid 파라미터 무시 (DB에 없으니까 사용 안 함)

    // 나머지 파라미터
    String sCategoryCd = request.getParameter("categoryCd");
    String sProductName = request.getParameter("productName");
    String sProductPrice = request.getParameter("productPrice");
    String sProductQuantity = request.getParameter("productQuantity");
    String sProductDesc = request.getParameter("productDesc");

    PreparedStatement pstmt = null;

    try {
        if (conn == null || conn.isClosed()) {
            out.println("<p style='color:red;'>데이터베이스 연결이 없습니다.</p>");
            return;
        }

        StringBuilder sql = new StringBuilder();

        if ("I".equals(sActionMethod)) {
            // INSERT (SHOP_UUID 제거)
            sql.append("INSERT INTO PRODUCT ( \n");
            sql.append("  PRODUCT_UUID, CATEGORY_CD, PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_QUANTITY, PRODUCT_DESC, REG_DT, UPT_DT \n");
            sql.append(") VALUES ( \n");
            sql.append("  SYS_GUID(), ?, ?, ?, ?, ?, SYSDATE, SYSDATE \n");
            sql.append(")");

            pstmt = conn.prepareStatement(sql.toString());
            pstmt.setString(1, sCategoryCd);
            pstmt.setString(2, sProductName);
            pstmt.setString(3, sProductPrice);
            pstmt.setString(4, sProductQuantity);
            pstmt.setString(5, sProductDesc);

        } else if ("U".equals(sActionMethod)) {
            // UPDATE
            if (sProductUuid == null || sProductUuid.trim().isEmpty()) {
                out.println("<p style='color:red;'>수정할 상품 UUID가 없습니다.</p>");
                return;
            }

            sql.append("UPDATE PRODUCT SET \n");
            sql.append("  CATEGORY_CD = ?, \n");
            sql.append("  PRODUCT_NAME = ?, \n");
            sql.append("  PRODUCT_PRICE = ?, \n");
            sql.append("  PRODUCT_QUANTITY = ?, \n");
            sql.append("  PRODUCT_DESC = ?, \n");
            sql.append("  UPT_DT = SYSDATE \n");
            sql.append("WHERE PRODUCT_UUID = ?");

            pstmt = conn.prepareStatement(sql.toString());
            pstmt.setString(1, sCategoryCd);
            pstmt.setString(2, sProductName);
            pstmt.setString(3, sProductPrice);
            pstmt.setString(4, sProductQuantity);
            pstmt.setString(5, sProductDesc);
            pstmt.setString(6, sProductUuid);
        } else {
            out.println("<p style='color:red;'>잘못된 요청입니다.</p>");
            return;
        }

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('저장이 완료되었습니다.'); location.href='productMag.jsp';</script>");
        } else {
            out.println("<p style='color:red;'>저장에 실패했습니다.</p>");
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>오류가 발생했습니다: " + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
