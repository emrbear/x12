require 'x12'
require 'test/unit'

# Loop 2410 (drug identification) must render in the 5010 837 form: unused
# LIN and CTP elements are left empty instead of being padded with blanks.
class Test837DrugIdentification < Test::Unit::TestCase

  DEFINITIONS = {
    '837p' => 'bundled_837p.xml',
    '837i' => '837i.xml'
  }

  def l2400_for(root)
    factory = X12::Parser.new(DEFINITIONS[root]).factory(root)
    l2300   = root == '837p' ? factory.L837.L2300.repeat : factory.L837.L2300
    l2300.L2400.repeat
  end

  def fill_drug_loop(l2400)
    l2410 = l2400.L2410
    l2410.LIN.ProductServiceIdQualifier1 = 'N4'
    l2410.LIN.ProductServiceId1          = '12345678901'
    l2410.CTP.Quantity                   = '60'
    l2410.CTP.CompositeUnitOfMeasure     = 'ML'
    l2410
  end

  DEFINITIONS.each_key do |root|
    define_method("test_#{root}_lin_renders_without_padding") do
      assert_equal('LIN**N4*12345678901~', fill_drug_loop(l2400_for(root)).LIN.render)
    end

    define_method("test_#{root}_ctp_renders_without_padding") do
      assert_equal('CTP****60*ML~', fill_drug_loop(l2400_for(root)).CTP.render)
    end

    define_method("test_#{root}_empty_drug_loop_renders_nothing") do
      assert_equal('', l2400_for(root).L2410.render)
    end
  end
end
