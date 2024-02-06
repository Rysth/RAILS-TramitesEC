# Seed Users
User.create(username: "John Palacios", email: "admin@test.com", password: "123456")
User.create(username: "Ericka Contreras", email: "ericka.c@test.com", password: "123456")
User.create(username: "William Briones", email: "william.b@test.com", password: "123456")
User.create(username: "Gabriela Sanchéz", email: "gabriela.s@test.com", password: "123456")


# Seed Processors with Faker data
500.times do
  Processor.create(
    nombres: Faker::Name.first_name,
    apellidos: Faker::Name.last_name,
    celular: Faker::Number.number(digits: 10),
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    user_id: User.ids.sample
  )
end

# Seed Clientes with Faker data
1000.times do
  Customer.create(
    cedula: Faker::Number.number(digits: 10),
    nombres: Faker::Name.first_name,
    apellidos: Faker::Name.last_name,
    celular: Faker::Number.number(digits: 10),
    direccion: Faker::Address.street_address,
    email: Faker::Internet.email,
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    processor_id: Processor.ids.sample,
    user_id: User.ids.sample
  )
end

# Seed Types
Type.create(nombre: "Renovación")
Type.create(nombre: "Tipo de Sangre")
Type.create(nombre: "Revisión")
Type.create(nombre: "Observación Laminas Oscuras")
Type.create(nombre: "Certificados sin Deuda")
Type.create(nombre: "Certificados con Deuda")
Type.create(nombre: "Revisión Transporte Público")
Type.create(nombre: "Cambio de Propietario")
Type.create(nombre: "Cambio de Color")
Type.create(nombre: "Duplicado AAA")
Type.create(nombre: "Duplicado de Licencia")
Type.create(nombre: "Cambio de Propietario Directo")
Type.create(nombre: "Gravamen")
Type.create(nombre: "Desbloqueo de Licencia")
Type.create(nombre: "Licencia Anclada")
Type.create(nombre: "Título")
Type.create(nombre: "Revisión ATM Particulares")
Type.create(nombre: "Cambio de Comercial/Particular")
Type.create(nombre: "RTV Alquiler")
Type.create(nombre: "RTV Particular")
Type.create(nombre: "Ingreso de Vehículo")
Type.create(nombre: "Recuperación de Puntos")
Type.create(nombre: "Primera Vez No Profesionales")
Type.create(nombre: "Licencias Profesionales")
Type.create(nombre: "CUV")
Type.create(nombre: "Actualización de Datos")

# Seed Licenses
License.create(type_id: 2, nombre: "A1")
License.create(type_id: 2, nombre: "C")
License.create(type_id: 2, nombre: "C1")
License.create(type_id: 2, nombre: "D")
License.create(type_id: 2, nombre: "E")
License.create(type_id: 2, nombre: "E1")
License.create(type_id: 2, nombre: "G")
License.create(type_id: 3, nombre: "A")
License.create(type_id: 3, nombre: "B")
License.create(type_id: 3, nombre: "F")

# Seed Statuses
Status.create(nombre: "Entregado Proveedor")
Status.create(nombre: "En Proceso")
Status.create(nombre: "Entregado Cliente")
Status.create(nombre: "Envíado Brevetar")

# Seed Procedures with Faker data
500.times do
  Procedure.create(
    placa: Faker::Vehicle.license_plate,
    valor: Faker::Number.decimal(l_digits: 3, r_digits: 2),
    valor_pendiente: Faker::Number.decimal(l_digits: 2, r_digits: 2),
    ganancia: Faker::Number.decimal(l_digits: 2, r_digits: 2),
    ganancia_pendiente: Faker::Number.decimal(l_digits: 2, r_digits: 2),
    observaciones: Faker::Lorem.sentence,
    user_id: User.ids.sample,
    processor_id: Processor.ids.sample,
    customer_id: Customer.ids.sample,
    type_id: Type.ids.sample,
    license_id: License.ids.sample,
    status_id: Status.ids.sample
  )
end