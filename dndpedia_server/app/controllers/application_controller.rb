require 'pry'

class ApplicationController < Sinatra::Base
  set :default_content_type, 'application/json'

  get '/characters' do
    all_characters = Character.all
    all_characters.each { |char| char.update(spell_points: char.spells.map { |spell| spell["level"] * spell["damage"] * spell["description"].length/8 }.reduce(:+))}

    all_spells = Spell.all

    return all_spells.to_json + all_characters.to_json(include: :spells)
  end

  post '/create_a_character' do
    level = params[:level]
    melee_weapon = Faker::Games::DnD.melee_weapon
    melee_weapon_source = RestClient.get "https://www.dnd5eapi.co/api/equipment/#{melee_weapon.downcase.gsub(" ", "-")}"
    melee_weapon_json = JSON.parse(melee_weapon_source)
    melee_weapon_power = melee_weapon_json["range"].values[0] * melee_weapon_json["weight"]
    ranged_weapon_location = Faker::Games::DnD.ranged_weapon
    ranged_weapon = ranged_weapon_location == "Crossbow" || ranged_weapon_location == "Boomerang" ? "Blowgun" : ranged_weapon_location
    ranged_weapon_source = RestClient.get "https://www.dnd5eapi.co/api/equipment/#{ranged_weapon.downcase.gsub(" ", "-")}"
    ranged_weapon_json = JSON.parse(ranged_weapon_source)
    ranged_weapon_power = ranged_weapon_json["range"].values[1] * ranged_weapon_json["weight"]
    new_character = Character.create(
      name: params[:name],
      alignment: Faker::Games::DnD.alignment,
      background: Faker::Games::DnD.background,
      city: params[:city],
      c_lass: Faker::Games::DnD.klass,
      language: params[:language],
      melee_weapon: melee_weapon,
      pet: params[:pet],
      race: Faker::Games::DnD.race,
      ranged_weapon: ranged_weapon,
      level: level,
      attack_points: ranged_weapon_power * melee_weapon_power * level.to_i,
      spell_points: 0,
      avatar_url: params[:avatar_url]
    )
    new_character.to_json
  end

  delete '/characters/:id' do
    character = Character.find(params[:id])
    character.destroy
    character.to_json
  end

  patch '/characters/:id' do
    character = Character.find(params[:id])
    character.update(
      name: params[:name],
      pet: params[:pet],
      level: params[:level],
      city: params[:city],
      avatar_url: params[:avatar_url],
      language: params[:language]
    )
    character.to_json
  end
  
end