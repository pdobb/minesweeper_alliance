# frozen_string_literal: true

Coordinates =
  Data.define(:x, :y) {
    def inspect
      "(#{x}, #{y})"
    end

    def to_s
      inspect
    end

    # rubocop:disable all
    def neighbors
      [
        with(x: x.pred, y: y.pred), with(y: y.pred), with(x: x.next, y: y.pred),
        with(x: x.pred           ),                  with(x: x.next           ),
        with(x: x.pred, y: y.next), with(y: y.next), with(x: x.next, y: y.next),
      ]
    end
    # rubocop:enable all

    def render
      "(#{x}, #{y})"
    end
  }
