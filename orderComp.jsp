<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="dbconn.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String orderUuid = request.getParameter("orderUuid");
    String orderStatus = request.getParameter("orderStatus");

    if (orderUuid != null && !orderUuid.isEmpty() &&
        orderStatus != null && !orderStatus.isEmpty()) {

        StringBuffer sql = new StringBuffer();
        sql.append("UPDATE ORDER_MASTER SET \n");
        sql.append(" ORDER_STATUS = ? \n");
        sql.append(" WHERE ORDER_UUID = ?");

        PreparedStatement pstmt = null;
        try {
            pstmt = conn.prepareStatement(sql.toString());
            pstmt.setString(1, orderStatus);
            pstmt.setString(2, orderUuid);
            int result = pstmt.executeUpdate();

            // 업데이트 성공 여부에 따라 처리 가능 (필요시 메시지 추가)

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }

    // 업데이트 후 목록 페이지로 이동
    response.sendRedirect("orderMag.jsp");
%>
