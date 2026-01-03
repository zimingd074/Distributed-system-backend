package com.distributed.monitor.util;

import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.BaseColor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.List;

/**
 * 报表文件生成工具（支持 Excel 和 PDF）
 */
public final class ReportFileGenerator {

    private ReportFileGenerator() {}

    /**
     * 使用 Apache POI 生成 Excel 文件
     * @param headers 表头
     * @param rows    每行字符串列表
     * @param file    输出文件（包含扩展名）
     * @throws Exception on error
     */
    public static void generateExcel(List<String> headers, List<List<String>> rows, File file) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Report");

            // header style
            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // header
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.size(); i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers.get(i));
                cell.setCellStyle(headerStyle);
            }

            // rows
            for (int r = 0; r < rows.size(); r++) {
                Row row = sheet.createRow(r + 1);
                List<String> cols = rows.get(r);
                for (int c = 0; c < cols.size(); c++) {
                    Cell cell = row.createCell(c);
                    cell.setCellValue(cols.get(c) != null ? cols.get(c) : "");
                }
            }

            // auto-size columns after writing rows
            for (int i = 0; i < headers.size(); i++) {
                sheet.autoSizeColumn(i);
            }

            // freeze header row
            sheet.createFreezePane(0, 1);

            // ensure parent dirs
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            try (OutputStream os = new FileOutputStream(file)) {
                workbook.write(os);
                os.flush();
            }
        }
    }

    /**
     * 使用 iText 生成简单的 PDF 表格文件
     * @param headers 表头
     * @param rows 每行字符串列表
     * @param file 输出文件
     * @throws Exception on error
     */
    public static void generatePdf(List<String> headers, List<List<String>> rows, File file) throws Exception {
        Document document = new Document(PageSize.A4.rotate(), 36, 36, 36, 36);
        try {
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            PdfWriter.getInstance(document, new FileOutputStream(file));
            document.open();

            // Title
            Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
            Paragraph title = new Paragraph("Report", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(new Paragraph(" "));

            // Table with headers
            PdfPTable table = new PdfPTable(headers.size());
            table.setWidthPercentage(100);

            // compute column widths based on max content length per column, scale to avoid wrapping
            float[] widths = new float[headers.size()];
            for (int i = 0; i < headers.size(); i++) {
                int maxLen = headers.get(i) != null ? headers.get(i).length() : 1;
                for (List<String> row : rows) {
                    if (row != null && row.size() > i) {
                        String cell = row.get(i);
                        if (cell != null) {
                            // treat multi-byte chars as length 2 for rough estimate
                            maxLen = Math.max(maxLen, cell.length());
                        }
                    }
                }
                // scale: each character roughly 7 units, ensure minimum width
                widths[i] = Math.max(30f, maxLen * 7f);
            }
            try {
                table.setWidths(widths);
            } catch (Exception ignored) {}

            // Try loading an embedded Chinese-capable font from classpath (/fonts/*.ttf or .otf).
            BaseFont baseFont = null;
            java.io.InputStream fontStream = null;
            try {
                // try common bundled names (you should add a real font file under src/main/resources/fonts/)
                fontStream = ReportFileGenerator.class.getResourceAsStream("/fonts/NotoSansCJKsc-Regular.otf");
                if (fontStream == null) {
                    fontStream = ReportFileGenerator.class.getResourceAsStream("/fonts/simsun.ttf");
                }
                if (fontStream != null) {
                    java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
                    byte[] buffer = new byte[4096];
                    int read;
                    while ((read = fontStream.read(buffer)) != -1) {
                        baos.write(buffer, 0, read);
                    }
                    byte[] fontBytes = baos.toByteArray();
                    // create BaseFont from bytes and embed it
                    baseFont = BaseFont.createFont("font.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED, true, fontBytes, null);
                } else {
                    // fallback to system CJK font mapping if available
                    try {
                        baseFont = BaseFont.createFont("STSong-Light", "UniGB-UCS2-H", BaseFont.NOT_EMBEDDED);
                    } catch (Exception ignored2) {
                        baseFont = null;
                    }
                }
            } catch (Exception ignored) {
                baseFont = null;
            } finally {
                if (fontStream != null) {
                    try { fontStream.close(); } catch (Exception ignored) {}
                }
            }

            Font headerFont = null;
            Font cellFont = null;
            if (baseFont != null) {
                headerFont = new Font(baseFont, 11, Font.BOLD, BaseColor.WHITE);
                cellFont = new Font(baseFont, 10, Font.NORMAL, BaseColor.BLACK);
            } else {
                headerFont = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, BaseColor.WHITE);
                cellFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, BaseColor.BLACK);
            }

            for (String h : headers) {
                PdfPCell cell = new PdfPCell(new Paragraph(h != null ? h : "", headerFont));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                cell.setBackgroundColor(BaseColor.GRAY);
                cell.setPadding(6f);
                table.addCell(cell);
            }
            table.setHeaderRows(1);

            for (List<String> row : rows) {
                for (int i = 0; i < headers.size(); i++) {
                    String col = "";
                    if (row != null && row.size() > i && row.get(i) != null) {
                        col = row.get(i);
                    }
                    PdfPCell cell = new PdfPCell(new Paragraph(col, cellFont));
                    cell.setPadding(4f);
                    cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                    table.addCell(cell);
                }
            }

            document.add(table);
        } finally {
            document.close();
        }
    }
}


