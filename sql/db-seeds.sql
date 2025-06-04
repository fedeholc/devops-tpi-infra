-- Evitar conflictos de claves externas al recrear
SET FOREIGN_KEY_CHECKS = 0;

-- Insert de prueba
INSERT INTO Areas (id, nombre, descripcion) VALUES 
(1, 'Electricidad', 'Servicios eléctricos generales'),
(2, 'Plomería', 'Instalaciones y reparaciones de plomería'),
(3, 'Gas', 'Servicios de instalación y reparación de gas'),
(4, 'Pintura', 'Trabajos de pintura y decoración'),
(5, 'Carpintería', 'Servicios de carpintería en general'),
(6, 'Albañilería', 'Trabajos de albañilería y construcción');

INSERT INTO Usuario (id, email, password, rol) VALUES
(1, 'admin@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'admin'),
(2, 'cliente@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'cliente'),
(3, 'tecnico@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'tecnico'),
(4, 'cliente1@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'cliente'),
(5, 'cliente2@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'cliente'),
(6, 'cliente3@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'cliente'),
(7, 'cliente4@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'cliente'),
(8, 'cliente5@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'cliente'),
(9, 'tecnico1@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'tecnico'),
(10, 'tecnico2@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'tecnico'),
(11, 'tecnico3@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'tecnico'),
(12, 'tecnico4@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'tecnico'),
(13, 'tecnico5@test.com', '$2b$10$o5YP9MjZPxa0hbJlbD.kteMQsCwj/Mn1uTAJGK2I2cdZTvRDQVHo2', 'tecnico');

INSERT INTO Cliente (id, usuarioId, nombre, apellido, telefono, direccion) VALUES
(1, 2, 'Juan', 'Pérez', '1122334455', 'Av. Siempre Viva 123'),
(2, 4, 'Ana', 'Martínez', '1111111111', 'Calle 1 100'),
(3, 5, 'Luis', 'Fernández', '2222222222', 'Calle 2 200'),
(4, 6, 'María', 'García', '3333333333', 'Calle 3 300'),
(5, 7, 'Pedro', 'López', '4444444444', 'Calle 4 400'),
(6, 8, 'Sofía', 'Díaz', '5555555555', 'Calle 5 500');

INSERT INTO Tecnico (id, usuarioId, nombre, apellido, telefono, direccion, caracteristicas) VALUES
(1, 3, 'Carlos', 'Gómez', '1199887766', 'Calle Falsa 456', 'Especialista en instalaciones domiciliarias'),
(2, 9, 'Miguel', 'Ruiz', '6666666666', 'Calle 6 600', 'Especialista en plomería'),
(3, 10, 'Laura', 'Sosa', '7777777777', 'Calle 7 700', 'Experta en gas'),
(4, 11, 'Javier', 'Mendoza', '8888888888', 'Calle 8 800', 'Pintor profesional'),
(5, 12, 'Valeria', 'Castro', '9999999999', 'Calle 9 900', 'Carpintería y muebles'),
(6, 13, 'Andrés', 'Silva', '1010101010', 'Calle 10 1000', 'Albañilería y reformas');

INSERT INTO TecnicoAreas (id, tecnicoId, areaId) VALUES 
(1, 1, 1), -- Carlos Gómez: Electricidad
(2, 1, 2), -- Carlos Gómez: Plomería
(3, 2, 2), -- Miguel Ruiz: Plomería
(4, 2, 3), -- Miguel Ruiz: Gas
(5, 3, 3), -- Laura Sosa: Gas
(6, 3, 4), -- Laura Sosa: Pintura
(7, 4, 4), -- Javier Mendoza: Pintura
(8, 4, 5), -- Javier Mendoza: Carpintería
(9, 5, 5), -- Valeria Castro: Carpintería
(10, 5, 6), -- Valeria Castro: Albañilería
(11, 6, 6), -- Andrés Silva: Albañilería
(12, 6, 1); -- Andrés Silva: Electricidad

INSERT INTO Pedido (id, clienteId, tecnicoId, estado, areaId, requerimiento, calificacion, comentario, respuesta, fechaCreacion, fechaCierre, fechaCancelado) VALUES
(1, 1, null, 'sin_candidatos', 1, 'Reparación de toma corriente', NULL, NULL, NULL, NOW(), NULL, NULL),
(2, 2, null, 'con_candidatos', 2, 'Arreglo de caño roto en baño', NULL, NULL, NULL, NOW(), NULL, NULL),
(3, 3, 3, 'tecnico_seleccionado', 3, 'Revisión de instalación de gas', NULL, NULL, NULL, NOW(), NULL, NULL),
(4, 4, null, 'cancelado', 4, 'Pintar habitación principal', NULL, NULL, NULL, NOW(), NULL, NOW()),
(5, 5, 5, 'finalizado', 5, 'Reparar puerta de madera', 5, 'Excelente trabajo', 'Gracias por la confianza', NOW(), NOW(), NULL);

INSERT INTO PedidoDisponibilidad (id, pedidoId, clienteId, dia, horaInicio, horaFin) VALUES
(1, 1, 1, 'lunes', '09:00:00', '12:00:00'),
(2, 1, 1, 'martes', '10:00:00', '13:00:00'),
(3, 1, 1, 'miércoles', '14:00:00', '17:00:00'),
(4, 1, 1, 'jueves', '15:00:00', '18:00:00'),
(5, 1, 1, 'viernes', '16:00:00', '19:00:00'),

-- Pedido 2
(6, 2, 2, 'lunes', '08:00:00', '10:00:00'),
(7, 2, 2, 'miércoles', '11:00:00', '13:00:00'),

-- Pedido 3
(8, 3, 3, 'martes', '09:30:00', '12:30:00'),
(9, 3, 3, 'jueves', '14:00:00', '16:00:00'),

-- Pedido 4
(10, 4, 4, 'viernes', '10:00:00', '12:00:00'),
(11, 4, 4, 'sábado', '15:00:00', '18:00:00'),

-- Pedido 5
(12, 5, 5, 'lunes', '13:00:00', '15:00:00'),
(13, 5, 5, 'miércoles', '16:00:00', '18:00:00');

INSERT INTO PedidoCandidatos (id, pedidoId, tecnicoId) VALUES
-- Pedido 5
(1, 5, 1),
(2, 5, 5),
(3, 5, 3),

-- Pedido 2
(4, 2, 2),
(5, 2, 3),
(6, 2, 4),

-- Pedido 3
(7, 3, 3),
(8, 3, 4),
(9, 3, 5),

-- Pedido 4
(10, 4, 4),
(11, 4, 5),
(12, 4, 6);

INSERT INTO Factura (id, usuarioId, descripcion, total, metodoPago) VALUES
(1, 2, 'Suscripción Cuota 1/25', 500.00, 'tarjeta'),
-- Técnico 1 (usuarioId: 3)
(2, 3, 'Suscripción Cuota 1/25', 500.00, 'tarjeta'),
(3, 3, 'Suscripción Cuota 2/25', 600.00, 'transferencia'),
-- Técnico 2 (usuarioId: 9)
(4, 9, 'Suscripción Cuota 1/25', 500.00, 'tarjeta'),
(5, 9, 'Suscripción Cuota 2/25', 600.00, 'transferencia'),
-- Técnico 3 (usuarioId: 10)
(6, 10, 'Suscripción Cuota 1/25', 500.00, 'tarjeta'),
(7, 10, 'Suscripción Cuota 2/25', 600.00, 'transferencia'),
-- Técnico 4 (usuarioId: 11)
(8, 11, 'Suscripción Cuota 1/25', 500.00, 'tarjeta'),
(9, 11, 'Suscripción Cuota 2/25', 600.00, 'transferencia'),
-- Técnico 5 (usuarioId: 12)
(10, 12, 'Suscripción Cuota 1/25', 500.00, 'tarjeta'),
(11, 12, 'Suscripción Cuota 2/25', 600.00, 'transferencia'),
-- Técnico 6 (usuarioId: 13)
(12, 13, 'Suscripción Cuota 1/25', 500.00, 'tarjeta'),
(13, 13, 'Suscripción Cuota 2/25', 600.00, 'transferencia');

-- Reactivar claves foráneas
SET FOREIGN_KEY_CHECKS = 1;
