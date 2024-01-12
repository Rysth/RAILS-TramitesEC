# Seed Users
User.create(username: "John Palacios", email: "admin@test.com", password: "123456")
User.create(username: "Ericka Briones", email: "ericka.b@test.com", password: "123456")
User.create(username: "William Briones", email: "william.b@test.com", password: "123456")
User.create(username: "Gabriela Sanchéz", email: "gabriela.s@test.com", password: "123456")


# Seed Processors with Faker data
10.times do
  Processor.create(
    nombres: Faker::Name.first_name,
    apellidos: Faker::Name.last_name,
    celular: Faker::PhoneNumber.cell_phone,
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    user_id: User.ids.sample
  )
end

# Seed Clientes with Faker data
10.times do
  Customer.create(
    cedula: Faker::IDNumber.unique.spanish_citizen_number,
    nombres: Faker::Name.first_name,
    apellidos: Faker::Name.last_name,
    celular: Faker::PhoneNumber.cell_phone,
    direccion: Faker::Address.street_address,
    email: Faker::Internet.email,
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    processor_id: Processor.ids.sample,
    user_id: User.ids.sample
  )
end

# Seed Types
Type.create(nombre: "Renovación")
Type.create(nombre: "Profesional")
Type.create(nombre: "No Profesional")

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

# Seed Statusese
Status.create(nombre: "EN PROCESO")
Status.create(nombre: "ENTREGADO AL CLIENTE")
Status.create(nombre: "ENTREGADO POR EL PROVEEDOR")

# Seed Procedures with Faker data
100.times do
  Procedure.create(
    placa: Faker::Vehicle.license_plate,
    valor: Faker::Number.decimal(l_digits: 3, r_digits: 2),
    valor_pendiente: Faker::Number.decimal(l_digits: 3, r_digits: 2),
    ganancia: Faker::Number.decimal(l_digits: 3, r_digits: 2),
    ganancia_pendiente: Faker::Number.decimal(l_digits: 3, r_digits: 2),
    observaciones: Faker::Lorem.sentence,
    user_id: User.ids.sample,
    processor_id: Processor.ids.sample,
    customer_id: Customer.ids.sample,
    type_id: Type.ids.sample,
    license_id: License.ids.sample,
    status_id: Status.ids.sample
  )
end