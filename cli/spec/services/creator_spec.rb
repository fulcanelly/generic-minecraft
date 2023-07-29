require 'spec_helper'

puts 9
# vcr: { allow_playback_repeats: true }
RSpec.describe ConfigGeneratorService, :vcr do
  describe '#plugins_from_file_names' do
    context 'when some names provided' do
      let(:input_file_names) do
        [
          "CoreProtect-21.3.jar",
          "InvSee++.jar",
          "InventProtect-1.3.jar",
          "ChestSort-13.5.1.jar",
          "LuckPerms-Bukkit-5.3.86.jar",
          "SinglePlayerSleep-1.13_2.13.49.jar",
          "ViaBackwards-4.5.1.jar",
          "InviteSystemCore-1.0.jar",
          "ProtocolLib.jar",
          "Suicider-2015-06-24.jar",
          "ViaVersion-4.5.1.jar",
          "orebfuscator-plugin-5.3.3.jar"]
      end

      let(:expected_output) do
        [{ :name => "CoreProtect", :resource_id => 8631, :source => :spigot },
         { :name => "InvSee++", :source => :spigot, :resource_id => 82342 },
         { :name => "InventProtect-1.3", :source => :unknown },
         { :name => "ChestSort (+ API)", :source => :spigot, :resource_id => 59773 },
         { :name => "LuckPerms", :resource_id => 28140, :source => :spigot },
         { :name => "SinglePlayerSleep", :source => :spigot, :resource_id => 68139 },
         { :name => "ViaBackwards", :source => :spigot, :resource_id => 27448 },
         { :name => "InviteSystemCore-1.0", :source => :unknown },
         { :name => "ProtocolLib", :source => :spigot, :resource_id => 1997 },
         { :name => "Suicider", :source => :spigot, :resource_id => 8623 },
         { :name => "ViaVersion", :source => :spigot, :resource_id => 19254 },
         { :name => "Orebfuscator", :source => :spigot, :resource_id => 22818 }]
      end

      it 'should try to find source' do
        expect(described_class.plugins_from_file_names(input_file_names)).to eq(expected_output)
      end
    end
  end

  describe '#verify_plugins' do
    let(:input_plugins) do
      [{ :name => "InvSee++", :source => :spigot, :resource_id => 82342 },
       { :name => "InventProtect-1.3", :source => :unknown }]
    end

    let(:expected_output) do
      [{ :warn => "Can't load plugin, unknown source" }]
    end

    context 'when source is unknown' do
      it 'should produce warning' do
        expect(described_class.verify_plugins(input_plugins)).to eq(expected_output)
      end
    end
  end

  describe '#plugin_from_jar_files' do
    context 'when version is speicified in jar' do
      it 'extracts author, version and uses it when searching', skip: 'todo'
    end
  end

end
