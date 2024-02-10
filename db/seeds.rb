#Seed Rols
Rol.create(name: "Administrador", active: true)
Rol.create(name: "Usuario", active: true)

# Seed Users
User.create(username: "John Palacios", email: "admin@test.com", password: "123456", active: true)
User.create(username: "Ericka Contreras", email: "ericka.c@test.com", password: "123456", active: true)
User.create(username: "William Briones", email: "william.b@test.com", password: "123456", active: true)
User.create(username: "Gabriela Sanchéz", email: "gabriela.s@test.com", password: "123456", active: true)


# Seed Processors with Faker data
50.times do
  Processor.create(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone: Faker::Number.number(digits: 10),
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    id_user: User.ids.sample
  )
end

# Seed Clientes with Faker data
100.times do
  Customer.create(
    identification: Faker::Number.number(digits: 10),
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone: Faker::Number.number(digits: 10),
    email: Faker::Internet.email,
    address: Faker::Address.street_address,
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    is_direct: Faker::Boolean.boolean(true_ratio: 0.8),
    id_processor: Processor.ids.sample,
    id_user: User.ids.sample
  )
end

# Seed ProcedureTypes
ProcedureType.create(name: "Revisión", active: true, has_children: true)
ProcedureType.create(name: "Renovación", active: true, has_children: false)
ProcedureType.create(name: "Título", active: true, has_children: false)  # Cursos Manejo (Primera Vez)
ProcedureType.create(name: "Ingresos", active: true, has_children: false) # Casos de Usuarios Directos
ProcedureType.create(name: "Recuperación de Puntos", active: true, has_children: false)
ProcedureType.create(name: "Duplicado AAA", active: true, has_children: false)
ProcedureType.create(name: "Duplicado de Licencia Original", active: true, has_children: false)
ProcedureType.create(name: "Desbloqueo de Licencia", active: true, has_children: false)
ProcedureType.create(name: "Licencia Anclada", active: true, has_children: false)
ProcedureType.create(name: "Actualización de Datos", active: true, has_children: true)
ProcedureType.create(name: "Observación Laminas Oscuras", active: true, has_children: false)
ProcedureType.create(name: "Certificados sin Deuda", active: true, has_children: false)
ProcedureType.create(name: "Certificados con Deuda", active: true, has_children: false)
ProcedureType.create(name: "Revisión Transporte Público", active: true, has_children: false)
ProcedureType.create(name: "Cambio de Propietario", active: true, has_children: false)
ProcedureType.create(name: "Cambio de Color", active: true, has_children: false)
ProcedureType.create(name: "Gravamen", active: true, has_children: true)
ProcedureType.create(name: "Revisión ATM Particulares", active: true, has_children: false)
ProcedureType.create(name: "Cambio de Comercial/Particular", active: true, has_children: false)
ProcedureType.create(name: "Ingreso de Vehículo", active: true, has_children: false)
ProcedureType.create(name: "Tipo de Sangre", active: true, has_children: false)
ProcedureType.create(name: "CUV", active: true, has_children: false)

# Seed ProcedureSubTypes
ProcedureSubType.create(name: "Visual", active: true, id_procedure_type: 1)
ProcedureSubType.create(name: "Comercial Técnica", active: true, id_procedure_type: 1)
ProcedureSubType.create(name: "Técnica", active: true, id_procedure_type: 1)
ProcedureSubType.create(name: "Vehículo", active: true, id_procedure_type: 10)
ProcedureSubType.create(name: "Licencia", active: true, id_procedure_type: 10)
ProcedureSubType.create(name: "Por Deuda", active: true, id_procedure_type: 17)
ProcedureSubType.create(name: "Inactividad", active: true, id_procedure_type: 17)
ProcedureSubType.create(name: "Vehículo Dado de Baja", active: true, id_procedure_type: 17)
ProcedureSubType.create(name: "Transferencia de Dominio", active: true, id_procedure_type: 17)

# Seed LicenseTypes
LicenseType.create(name: "No Profesionales", active: true)
LicenseType.create(name: "Profesionales", active: true)
LicenseType.create(name: "Especiales", active: true)

# Seed Licenses
License.create(name: "A", active: true, id_license_type: 1)
License.create(name: "B", active: true, id_license_type: 1)
License.create(name: "C", active: true, id_license_type: 2)
License.create(name: "D", active: true, id_license_type: 2)
License.create(name: "E", active: true, id_license_type: 2)
License.create(name: "A1", active: true, id_license_type: 3)
License.create(name: "C1", active: true, id_license_type: 3)
License.create(name: "E1", active: true, id_license_type: 3)
License.create(name: "G", active: true, id_license_type: 3)

# Seed Statuses
Status.create(name: "En Proceso")
Status.create(name: "Entregado Proveedor")
Status.create(name: "Envíado Brevetar") # Ej: Es un ingreso (Renovación, significa que me entrego una documentación) Paso Opcional
Status.create(name: "Entregado Cliente")

# Seed Procedures with Faker data
10.times do
  Procedure.create(
    cost: Faker::Number.decimal(l_digits: 3, r_digits: 2),
    cost_pending: Faker::Number.decimal(l_digits: 2, r_digits: 2),
    plate: Faker::Vehicle.license_plate,
    profit: Faker::Number.decimal(l_digits: 2, r_digits: 2),
    profit_pending: Faker::Number.decimal(l_digits: 2, r_digits: 2),
    comments: Faker::Lorem.sentence,
    is_paid: Faker::Boolean.boolean(true_ratio: 0.8),
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    id_user: User.ids.sample,
    id_processor: Processor.ids.sample,
    id_customer: Customer.ids.sample,
    id_procedure_type: ProcedureType.ids.sample,
    id_status: Status.ids.sample
    id_license: License.ids.sample,
  )
end