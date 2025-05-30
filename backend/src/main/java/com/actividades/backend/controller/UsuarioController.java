package com.actividades.backend.controller;

import com.actividades.backend.dto.GoogleLoginRequest;
import com.actividades.backend.dto.LoginRequest;
import com.actividades.backend.dto.LoginResponse;
import com.actividades.backend.dto.RegistroRequest;
import com.actividades.backend.model.VerificacionToken;
import com.actividades.backend.repository.UsuarioRepository;
import com.actividades.backend.repository.VerificacionTokenRespository;
import com.actividades.backend.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "http://localhost:59531")
public class UsuarioController {

    private final UsuarioService usuarioService;
    private final VerificacionTokenRespository tokenRespository;
    private final UsuarioRepository usuarioRepository;

    public UsuarioController(UsuarioService usuarioService, VerificacionTokenRespository tokenRespository, UsuarioRepository usuarioRepository) {
        this.usuarioService = usuarioService;
        this.tokenRespository = tokenRespository;
        this.usuarioRepository = usuarioRepository;
    }

    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@Valid @RequestBody RegistroRequest datos, BindingResult result) {
        if (result.hasErrors()) {
            String error = result.getFieldError().getDefaultMessage();
            return ResponseEntity.badRequest().body("Error de validación: " + error);
        }

        if (usuarioRepository.findByEmail(datos.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Ya existe un usuario con ese email.");
        }

        try {
            usuarioService.registrar(datos.getNombre(), datos.getEmail(), datos.getPassword());
            return ResponseEntity.ok("Registro exitoso. Revisa tu correo para confirmar la cuenta.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al registrar: " + e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest datos) {
        try {
            Optional<LoginResponse> respuesta = usuarioService.login(datos.getEmail(), datos.getPassword());

            if (respuesta.isPresent()) {
                return ResponseEntity.ok(respuesta.get());
            } else {
                return ResponseEntity.status(401).body("Credenciales inválidas");
            }

        } catch (IllegalStateException e) {
            return ResponseEntity.status(401).body(e.getMessage());
        }
    }

    @PostMapping("/google-login")
    public ResponseEntity<?> loginConGoogle(@RequestBody GoogleLoginRequest request) {
        try {
            LoginResponse respuesta = usuarioService.loginConGoogle(request.getIdToken());
            return ResponseEntity.ok(respuesta);
        } catch (Exception e) {
            return ResponseEntity.status(401).body("Token inválido: " + e.getMessage());
        }
    }

    @GetMapping("/confirmar")
    public ResponseEntity<String> confirmarCuenta(@RequestParam("token") String token) {
        Optional<VerificacionToken> tokenOpt = tokenRespository.findByToken(token);
        if (tokenOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Token inválido");
        }

        VerificacionToken vToken = tokenOpt.get();
        if (vToken.getFechaExpiracion().isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body("Token expirado");
        }

        var usuario = vToken.getUsuario();
        usuario.setVerificado(true);
        usuarioRepository.save(usuario);

        return ResponseEntity.ok("Cuenta confirmada con éxito. Ya puedes iniciar sesión");
    }

    @PostMapping("/recuperar")
    public ResponseEntity<?> recuperar(@RequestBody Map<String, String> body) {
        try {
            usuarioService.enviarCorreoRecuperacion(body.get("email"));
            return ResponseEntity.ok("Correo de recuperación enviado.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetearPassword(@RequestBody Map<String, String> datos) {
        String token = datos.get("token");
        String nuevaPassword = datos.get("nuevaPassword");

        try {
            boolean ok = usuarioService.resetearPassword(token, nuevaPassword);
            if (ok) {
                return ResponseEntity.ok("Contraseña actualizada con éxito.");
            } else {
                return ResponseEntity.badRequest().body("Token inválido o expirado.");
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
}