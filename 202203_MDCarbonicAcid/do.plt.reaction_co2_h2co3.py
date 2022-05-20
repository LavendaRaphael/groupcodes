import matplotlib.pyplot as plt
import matplotlib
from energydiagram import ED
from pyvalem.formula import Formula

matplotlib.rcParams['font.size']=15
matplotlib.rcParams['font.family']='sans-serif'
matplotlib.rcParams['font.sans-serif']=["Arial"]

diagram = ED()

list_e = [ 0.0, 18.8, 8.4, 12.8, 3.3 ]
list_t = []
for int_i in range(len(list_e)-1):
    list_t.append( (list_e[int_i]+list_e[int_i+1])/2 )

diagram.add_level(list_e[0],f'${Formula("CO2").latex}$(aq)')
diagram.add_level(list_e[1],'TS0')
diagram.add_level(list_e[2],f'${Formula("HCO3-").latex}$')
diagram.add_level(list_e[3],'TS1')
diagram.add_level(list_e[4],f'${Formula("H2CO3").latex}$')

diagram.add_link(0,1)
diagram.add_link(1,2)
diagram.add_link(2,3)
diagram.add_link(3,4)
diagram.plot()

diagram.space=5
diagram.plot()
print(diagram.space, diagram.dimension)
float_step = diagram.space + diagram.dimension
diagram.ax.text(float_step*1.5, list_t[0], '4.96 s',  bbox=dict(boxstyle='rarrow',facecolor='white'))
diagram.ax.text(float_step*2.5, list_t[1], '3.77 μs', bbox=dict(boxstyle='larrow',facecolor='white'))
diagram.ax.text(float_step*3.5, list_t[2], '0.16 ns', bbox=dict(boxstyle='rarrow',facecolor='white'))
diagram.ax.text(float_step*4.5, list_t[3], '0.83 μs', bbox=dict(boxstyle='larrow',facecolor='white'))

diagram.ax.set_ylabel('Energy (kcal/mol)')
diagram.fig.set_size_inches(15, 10)

plt.savefig('reaction_co2_h2co3.pdf', bbox_inches='tight')
plt.show()

