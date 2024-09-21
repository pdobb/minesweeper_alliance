# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  describe "User" do
    let(:unit_class) { User }

    let(:user1) { users(:user1) }
    let(:user2) { users(:user2) }

    describe ".first" do
      subject { unit_class }

      it "returns the expected User (ordered by 'created_at')" do
        _(subject.first).must_equal(user1)
      end
    end

    describe "#validate" do
      describe "#username" do
        subject { unit_class.new(username: username1) }

        context "GIVEN no #username" do
          let(:username1) { nil }

          it "passes validation" do
            subject.validate
            _(subject.errors[:username]).must_be_empty
          end
        end

        context "GIVEN #username < max length" do
          let(:username1) { "TEST" }

          it "passes validation" do
            subject.validate
            _(subject.errors[:username]).must_be_empty
          end
        end

        context "GIVEN #username > max length" do
          let(:username1) { "T" * max_length.next }
          let(:max_length) { unit_class::USERNAME_MAX_LEGNTH }

          it "fails validation" do
            subject.validate
            _(subject.errors[:username]).must_include(
              ValidationError.too_long(max_length))
          end
        end
      end
    end

    describe "#id" do
      subject { user1 }

      it "is a GUID" do
        result = subject.id
        _(result).must_be_instance_of(String)
      end
    end

    describe "#username=" do
      subject { user1 }

      context "GIVEN just white-space" do
        it "sets #username to nil" do
          subject.username = " "
          _(subject.username).must_be_nil
        end
      end

      context "GIVEN white-space before or after the given value" do
        it "sets the expected String" do
          subject.username = " TEST "
          _(subject.username).must_equal("TEST")
        end
      end
    end

    describe "#display_name" do
      context "GIVEN #username.present? = true" do
        subject { user1 }

        it "returns the expected String" do
          _(subject.display_name).must_match(/MMS-\d{4} "User1"/)
        end
      end

      context "GIVEN #username.blank? = true" do
        subject { user2 }

        it "returns the expected String" do
          _(subject.display_name).must_match(/MMS-\d{4}/)
        end
      end
    end

    describe "#mms_id" do
      before do
        MuchStub.(subject, :created_at) {
          Time.zone.local(2024, 1, 1, 12, 34, 56)
        }
      end

      subject { user1 }

      it "returns the expected String" do
        _(subject.mms_id).must_equal("MMS-4096")
      end
    end

    describe "#unique_id" do
      before do
        MuchStub.(subject, :created_at) {
          Time.zone.local(2024, 1, 1, 12, 34, 56)
        }
      end

      subject { user1 }

      it "returns the expected String" do
        _(subject.unique_id).must_equal("4096")
      end
    end

    describe "#signer?" do
      context "GIVEN a User that has signed their name" do
        subject { user1 }

        it "returns true" do
          _(subject.signer?).must_equal(true)
        end
      end

      context "GIVEN a User that has not signed their name" do
        subject { user2 }

        it "returns false" do
          _(subject.signer?).must_equal(false)
        end
      end
    end

    describe "#participated_in?" do
      let(:win1) { games(:win1) }
      let(:loss1) { games(:loss1) }

      subject { user2 }

      context "GIVEN a Game that the User has participated in" do
        it "returns true" do
          _(subject.participated_in?(loss1)).must_equal(true)
        end
      end

      context "GIVEN a Game that the User has not participated in" do
        subject { user2 }

        it "returns false" do
          _(subject.participated_in?(win1)).must_equal(false)
        end
      end
    end
  end
end
