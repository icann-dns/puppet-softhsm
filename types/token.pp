type Softhsm::Token = Struct[{
  pin    => Pattern[/\d{4,255}/],
  so_pin => Pattern[/\d{4,255}/],
}]
