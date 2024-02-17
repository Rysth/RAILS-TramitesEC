# Seed Users
User.create(username: "William Briones", email: "william.b@test.com", password: "123456", is_admin: true,  active: true)
User.create(username: "Ericka Contreras", email: "ericka.c@test.com", password: "123456", is_admin: false,  active: true)
User.create(username: "Gabriela Sanchéz", email: "gabriela.s@test.com", password: "123456", is_admin: false, active: true)

# Seed ProcedureTypes
ProcedureType.create(name: "Revisión", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "Renovación", active: true, has_licenses: true )
ProcedureType.create(name: "Título", active: true, has_licenses: true)  # Cursos Manejo (Primera Vez)
ProcedureType.create(name: "Ingresos", active: true, has_licenses: true) # Casos de Usuarios Directos
ProcedureType.create(name: "Recuperación de Puntos", active: true, has_licenses: false)
ProcedureType.create(name: "Duplicado AAA", active: true, has_licenses: false)
ProcedureType.create(name: "Duplicado de Licencia Original", active: true, has_licenses: false)
ProcedureType.create(name: "Desbloqueo de Licencia", active: true, has_licenses: false)
ProcedureType.create(name: "Licencia Anclada", active: true, has_licenses: false)
ProcedureType.create(name: "Actualización de Datos", active: true, has_licenses: false)
ProcedureType.create(name: "Observación Laminas Oscuras", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "Certificados sin Deuda", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "Certificados con Deuda", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "Revisión Transporte Público", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "Cambio de Propietario", active: true, has_licenses: false)
ProcedureType.create(name: "Cambio de Color", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "Gravamen", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "Revisión ATM Particulares", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "Cambio de Comercial/Particular", active: true, has_licenses: false)
ProcedureType.create(name: "Ingreso de Vehículo", active: true, has_licenses: false)
ProcedureType.create(name: "Tipo de Sangre", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)
ProcedureType.create(name: "CUV", active: true, has_licenses: false) # Registra Placa unicamente (Cliente opcional)

# Seed LicenseTypes
LicenseType.create(name: "No Profesionales", active: true)
LicenseType.create(name: "Profesionales", active: true)
LicenseType.create(name: "Especiales", active: true)

# Seed Licenses
License.create(name: "A", active: true, license_type_id: 1)
License.create(name: "B", active: true, license_type_id: 1)
License.create(name: "C", active: true, license_type_id: 2)
License.create(name: "D", active: true, license_type_id: 2)
License.create(name: "E", active: true, license_type_id: 2)
License.create(name: "A1", active: true, license_type_id: 3)
License.create(name: "C1", active: true, license_type_id: 3)
License.create(name: "E1", active: true, license_type_id: 3)
License.create(name: "G", active: true, license_type_id: 3)

# Seed Statuses
Status.create(name: "En Proceso")
Status.create(name: "Entregado Proveedor")
Status.create(name: "Envíado Brevetar") # Ej: Es un ingreso (Renovación, significa que me entrego una documentación) Paso Opcional va en relación con el Usuario Directo
Status.create(name: "Entregado Cliente")

# Seed Payments
PaymentType.create(name: "Efectivo")
PaymentType.create(name: "Transferencia Bancaria")
PaymentType.create(name: "Depósito")
