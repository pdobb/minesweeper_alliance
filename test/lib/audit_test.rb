# frozen_string_literal: true

require "test_helper"
require "audit"

class AuditTest < ActiveSupport::TestCase
  describe "Audit" do
    let(:unit_class) { Audit }

    let(:audit) {
      unit_class.new(obj1 => value1, obj2 => value2)
    }
    let(:empty_audit) { unit_class.new }
    let(:audit_json) { audit.to_h.to_json }
    let(:audit_string) { "#{value1} / #{value2}" }
    let(:obj1) { :obj1 }
    let(:obj2) { :obj2 }
    let(:value1) { "s1" }
    let(:value2) { "s2" }

    describe "Coder API" do
      subject { unit_class }

      describe ".load" do
        it "loads to an Audit Object" do
          _(subject.load(audit_json)).must_equal(audit)
        end
      end

      describe ".dump" do
        it "dumps to a JSON String" do
          _(subject.dump(audit)).must_equal(audit_json)
        end
      end
    end

    describe "#to_s" do
      context "GIVEN the Audit has values" do
        subject { audit }

        it "returns a String" do
          _(subject.to_s).must_be_instance_of(String)
        end

        it "returns the expected String" do
          _(subject.to_s).must_equal(audit_string)
        end

        context "GIVEN a custom separator" do
          it "returns the expected String" do
            target = "#{value1} :: #{value2}"
            _(subject.to_s(separator: " :: ")).must_equal(target)
          end
        end
      end

      context "GIVEN the Audit does not have values" do
        subject { empty_audit }

        it "returns an empty string" do
          _(subject.to_s).must_equal("")
        end
      end
    end

    describe "#[]" do
      subject { audit }

      context "GIVEN a known identifier" do
        it "returns the expected String, GIVEN a Symbol key" do
          _(subject[obj1.to_sym]).must_equal(value1)
        end

        it "returns the expected String, GIVEN a String key" do
          _(subject[obj1.to_s]).must_equal(value1)
        end
      end

      context "GIVEN an unknown identifier" do
        let(:unknown_identifier) { "UNKNOWN" }

        it "returns nil" do
          _(subject[unknown_identifier]).must_be_nil
        end
      end
    end
  end
end
