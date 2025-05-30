package com.actividades.backend.util;

public class EmailTemplateBuilder {

    public static String construirConfirmacion(String nombre, String link) {
        return "<!DOCTYPE html>"
                + "<html><body>"
                + "<p>Hola " + nombre + ",</p>"
                + "<p>Has solicitado restablecer tu contraseña. "
                + "Haz clic en el siguiente botón para continuar:</p>"
                + "<p><a href=\"" + link + "\" "
                +    "style=\"display:inline-block;padding:10px 20px;"
                +         "background:#6200EE;color:#fff;text-decoration:none;"
                +         "border-radius:4px;\">Restablecer contraseña</a></p>"
                + "<p>Si no fuiste tú, ignora este correo.</p>"
                + "</body></html>";

    }

    public static String construirRecuperacionManual(String nombre, String token) {
        return "<!DOCTYPE html>"
                + "<html><body style=\"font-family:Arial,sans-serif;line-height:1.6;\">"
                +   "<p>Hola " + nombre + ",</p>"
                +   "<p>Has solicitado restablecer tu contraseña en CulturAppFree.</p>"
                +   "<p><strong>Tu código de recuperación es:</strong></p>"
                +   "<pre style=\"font-size:18px;background:#f0f0f0;padding:12px;border-radius:4px;\">"
                +     token
                +   "</pre>"
                +   "<p>Cópialo y pégalo en la app donde se te solicite.</p>"
                +   "<p>Si no fuiste tú, ignora este correo.</p>"
                + "</body></html>";

    }
}