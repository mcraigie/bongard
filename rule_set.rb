# Author::    Max Craigie  (@MaxCraigie)
# Copyright:: Copyright (c) 2017 Max Craigie
# License::   Attribution-NonCommercial 3.0 Australia (CC BY-NC 3.0 AU)

require './grid.rb'
require './rule.rb'

module Bongard
  class RuleSet
    class << self
      def all
        rules = [
          anywhere,
          row_related,
          column_related,
          corner_cell_related,
          edge_cell_related,
          mirror_symmetry_related,
          rotation_symmetry_related,
        ].flatten
      end

      def anywhere
        rules = []

        Bongard::Grid.each_variety do |v|
          Bongard::Grid.each_coord do |c|
            rules << Bongard::Rule.new("variety #{v} @ #{c}") do |g|
              g.cell_at(*c).is(v)
            end
          end

          (0..4).each do |n|
            rules << Bongard::Rule.new("#{n} of variety #{v} in any cell") do |g|
              g.count { |c| c.is(v) } == n
            end
          end

          rules << Bongard::Rule.new("any of variety #{v} @ any cell") do |g|
            g.any? { |c| c.is(v) }
          end

        end

        rules
      end

      def row_related
        rules = []

        Bongard::Grid.each_row do |row|
          Bongard::Grid.each_variety do |v|
            (0..3).each do |n|
              rules << Bongard::Rule.new("#{n} of variety #{v} @ row #{row}") do |g|
                g.cells_in_row(row).count { |c| c.is(v) } == n
              end
            end
          end
        end

        rules
      end

      def column_related
        rules = []

        Bongard::Grid.each_col do |col|
          Bongard::Grid.each_variety do |v|
            (0..3).each do |n|
              rules << Bongard::Rule.new("#{n} of variety #{v} @ col #{col}") do |g|
                g.cells_in_col(col).count { |c| c.is(v) } == n
              end
            end
          end
        end

        rules
      end

      def corner_cell_related
        rules = []

        Bongard::Grid.each_variety do |v|
          (0..4).each do |n|
            rules << Bongard::Rule.new("#{n} of variety #{v} in corner cells") do |g|
              g.corner_cells.count { |c| c.is(v) } == n
            end
          end

          rules << Bongard::Rule.new("variety #{v} @ any corner cell") do |g|
            g.corner_cells.any? { |c| c.is(v) }
          end
        end

        rules
      end

      def edge_cell_related
        rules = []

        Bongard::Grid.each_variety do |v|
          (5..7).each do |n|
            rules << Bongard::Rule.new("#{n} of variety #{v} in edge cells") do |g|
              g.edge_cells.count { |c| c.is(v) } == n
            end
          end

          rules << Bongard::Rule.new("any of variety #{v} in edge cells") do |g|
            g.edge_cells.any? { |c| c.is(v) }
          end
        end

        rules
      end

      def mirror_symmetry_related
        rules = []

        # TODO: add diagnonal mirroring
        %i[vertical horizontal].each do |axis|
          rules << Bongard::Rule.new("mirrored #{axis}") { |g| g.mirror(axis) == g }
        end

        rules
      end

      def rotation_symmetry_related
        rules = []

        (1..2).each do |n|
          rules << Bongard::Rule.new("rotated clockwise # #{n}") do |g|
            g.rotate(:clockwise, n) == g
          end
        end

        rules
      end

    end
  end
end
