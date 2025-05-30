package com.actividades.backend.service;

import com.actividades.backend.model.Usuario;
import com.actividades.backend.model.VerificacionToken;
import com.actividades.backend.repository.UsuarioRepository;
import com.actividades.backend.repository.VerificacionTokenRespository;
import com.actividades.backend.util.EmailTemplateBuilder;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import jakarta.mail.MessagingException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import com.actividades.backend.dto.LoginResponse;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class UsuarioService {

    @Value("${app.url}")
    private String appUrl;

    private final UsuarioRepository usuarioRepository;
    private final VerificacionTokenRespository tokenRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final EmailService emailService;

    public UsuarioService(UsuarioRepository usuarioRepository,
                          VerificacionTokenRespository tokenRepository,
                          BCryptPasswordEncoder passwordEncoder,
                          EmailService emailService) {
        this.usuarioRepository = usuarioRepository;
        this.tokenRepository = tokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
    }

    /*Registro envío de email de confirmación */
    public Usuario registrar(String nombre, String email, String password) {
        // 1) Guardar usuario
        String hashed = passwordEncoder.encode(password);
        Usuario nuevo = new Usuario(nombre, email, hashed);
        Usuario saved = usuarioRepository.save(nuevo);

        // 2) Generar o actualizar token
        Optional<VerificacionToken> existente = tokenRepository.findByUsuario(saved);
        String token = UUID.randomUUID().toString();
        LocalDateTime expiracion = LocalDateTime.now().plusHours(24);
        VerificacionToken vToken = existente
                .map(t -> { t.setToken(token); t.setFechaExpiracion(expiracion); return t; })
                .orElseGet(() -> new VerificacionToken(token, saved, expiracion));
        tokenRepository.save(vToken);

        // 3) Construir link HTTP para confirmar cuenta
        String linkConfirmacion = appUrl + "/api/usuarios/confirmar?token=" + token;
        String contenidoHtml = EmailTemplateBuilder.construirConfirmacion(nombre, linkConfirmacion);

        // 4) Enviar email
        try {
            emailService.enviarHtml(
                    email,
                    "Confirma tu cuenta en CulturAppFree",
                    contenidoHtml
            );
        } catch (MessagingException e) {
            throw new RuntimeException("Error al enviar correo de confirmación: " + e.getMessage(), e);
        }

        return saved;
    }

    /* Login clásico */
    public Optional<LoginResponse> login(String email, String rawPassword) {
        Optional<Usuario> usuario = usuarioRepository.findByEmail(email);
        if (usuario.isPresent() && passwordEncoder.matches(rawPassword, usuario.get().getPassword())) {
            if (!usuario.get().getVerificado()) {
                throw new IllegalStateException("Cuenta no verificada");
            }
            Usuario u = usuario.get();
            return Optional.of(new LoginResponse(
                    u.getId(),
                    u.getNombreCompleto(),
                    u.getEmail(),
                    u.getOrigen(),
                    u.getActivo()
            ));
        }
        return Optional.empty();
    }

    public void enviarCorreoRecuperacion(String email) {
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("No existe un usuario con ese email."));

        tokenRepository.findByUsuario(usuario).ifPresent(tokenRepository::delete);


        String token = UUID.randomUUID().toString();
        LocalDateTime expiracion = LocalDateTime.now().plusHours(24);
        VerificacionToken tokenRecuperacion = new VerificacionToken(token, usuario, expiracion);
        tokenRepository.save(tokenRecuperacion);

        String html = EmailTemplateBuilder.construirRecuperacionManual(
                usuario.getNombreCompleto(),
                token
        );

        try {
            emailService.enviarHtml(
                    usuario.getEmail(),
                    "Código de recuperación – CulturAppFree",
                    html
            );
        } catch (MessagingException e) {
            throw new RuntimeException(
                    "Error al enviar correo de recuperación: " + e.getMessage(), e
            );
        }
    }


    public boolean resetearPassword(String token, String nuevaPassword) {
        Optional<VerificacionToken> tokenOpt = tokenRepository.findByToken(token);
        if (tokenOpt.isEmpty()) return false;

        VerificacionToken verificacion = tokenOpt.get();
        if (verificacion.getFechaExpiracion().isBefore(LocalDateTime.now())) {
            tokenRepository.delete(verificacion);
            return false;
        }

        Usuario usuario = verificacion.getUsuario();
        // 1) Actualizamos la contraseña
        usuario.setPassword(passwordEncoder.encode(nuevaPassword));
        // 2) Marcamos la cuenta como verificada para que el login permita el acceso
        usuario.setVerificado(true);
        usuarioRepository.save(usuario);

        // 3) Eliminamos el token
        tokenRepository.delete(verificacion);
        return true;
    }
    public LoginResponse loginConGoogle(String idToken) throws Exception {
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String email = decodedToken.getEmail();
        String nombre = (String) decodedToken.getClaims().get("name");

        Optional<Usuario> optionalUsuario = usuarioRepository.findByEmail(email);

        Usuario usuario = optionalUsuario.orElseGet(() -> {
            Usuario nuevo = new Usuario();
            nuevo.setEmail(email);
            nuevo.setNombreCompleto(nombre);
            nuevo.setOrigen("GOOGLE");
            nuevo.setActivo(true);
            nuevo.setVerificado(true);
            return usuarioRepository.save(nuevo);
        });

        return new LoginResponse(
                usuario.getId(),
                usuario.getNombreCompleto(),
                usuario.getEmail(),
                usuario.getOrigen(),
                usuario.getActivo()
        );
    }
}