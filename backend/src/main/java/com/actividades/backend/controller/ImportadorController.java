package com.actividades.backend.controller;

import com.actividades.backend.service.ImportadorEventosService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/importar")
@CrossOrigin(origins = "*")
public class ImportadorController {

    private final ImportadorEventosService importadorEventosService;

    public ImportadorController(ImportadorEventosService importadorEventosService) {
        this.importadorEventosService = importadorEventosService;
    }

    @PostMapping("/{ciudad}")
    public ResponseEntity<String> importarDesdeCiudad(@PathVariable String ciudad) {
        try {
            importadorEventosService.importarPorCiudad(ciudad);
            return ResponseEntity.ok("✅ Importación desde " + ciudad + " ejecutada correctamente.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("❌ Ciudad no válida: " + ciudad);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("❌ Error inesperado: " + e.getMessage());
        }
    }
}